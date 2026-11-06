CREATE TABLE IF NOT EXISTS app.fee (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE RESTRICT,
  academic_year_id uuid REFERENCES app.academic_year(id) ON DELETE RESTRICT,
  code text NOT NULL CHECK (char_length(code) BETWEEN 1 AND 50),
  name text NOT NULL CHECK (char_length(name) BETWEEN 2 AND 150),
  amount_minor bigint NOT NULL CHECK (amount_minor >= 0),
  currency char(3) NOT NULL DEFAULT 'XOF',
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'archived')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, code)
);

CREATE TABLE IF NOT EXISTS app.invoice (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE RESTRICT,
  student_id uuid NOT NULL REFERENCES app.student(id) ON DELETE RESTRICT,
  invoice_number text NOT NULL CHECK (char_length(invoice_number) BETWEEN 1 AND 60),
  issued_at timestamptz NOT NULL DEFAULT now(),
  due_at timestamptz,
  currency char(3) NOT NULL DEFAULT 'XOF',
  total_minor bigint NOT NULL CHECK (total_minor >= 0),
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'issued', 'partially_paid', 'paid', 'void', 'overdue')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, invoice_number)
);

CREATE TABLE IF NOT EXISTS app.invoice_line (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE RESTRICT,
  invoice_id uuid NOT NULL REFERENCES app.invoice(id) ON DELETE RESTRICT,
  fee_id uuid REFERENCES app.fee(id) ON DELETE RESTRICT,
  description text NOT NULL CHECK (char_length(description) BETWEEN 1 AND 300),
  amount_minor bigint NOT NULL CHECK (amount_minor >= 0),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS app.payment (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE RESTRICT,
  invoice_id uuid NOT NULL REFERENCES app.invoice(id) ON DELETE RESTRICT,
  reference text NOT NULL CHECK (char_length(reference) BETWEEN 1 AND 100),
  idempotency_key uuid NOT NULL,
  amount_minor bigint NOT NULL CHECK (amount_minor > 0),
  currency char(3) NOT NULL DEFAULT 'XOF',
  method text NOT NULL CHECK (method IN ('cash', 'mobile_money', 'bank_transfer', 'card', 'other')),
  status text NOT NULL DEFAULT 'confirmed' CHECK (status IN ('pending', 'confirmed', 'reversed', 'failed')),
  received_by_membership_id uuid REFERENCES app.membership(id) ON DELETE RESTRICT,
  paid_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, idempotency_key),
  UNIQUE (tenant_id, reference)
);

CREATE TABLE IF NOT EXISTS app.receipt (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE RESTRICT,
  payment_id uuid NOT NULL UNIQUE REFERENCES app.payment(id) ON DELETE RESTRICT,
  receipt_number text NOT NULL CHECK (char_length(receipt_number) BETWEEN 1 AND 60),
  issued_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, receipt_number)
);

CREATE TABLE IF NOT EXISTS app.refund (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE RESTRICT,
  payment_id uuid NOT NULL REFERENCES app.payment(id) ON DELETE RESTRICT,
  amount_minor bigint NOT NULL CHECK (amount_minor > 0),
  reason text NOT NULL CHECK (char_length(reason) BETWEEN 3 AND 500),
  status text NOT NULL DEFAULT 'requested' CHECK (status IN ('requested', 'approved', 'rejected', 'processed', 'cancelled')),
  requested_by_membership_id uuid NOT NULL REFERENCES app.membership(id) ON DELETE RESTRICT,
  approved_by_membership_id uuid REFERENCES app.membership(id) ON DELETE RESTRICT,
  approved_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK ((status IN ('approved', 'processed') AND approved_by_membership_id IS NOT NULL AND approved_at IS NOT NULL) OR status NOT IN ('approved', 'processed')),
  CHECK (approved_by_membership_id IS NULL OR approved_by_membership_id <> requested_by_membership_id)
);

CREATE TABLE IF NOT EXISTS app.audit_event (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE RESTRICT,
  actor_user_id text REFERENCES auth."user"(id) ON DELETE SET NULL,
  action text NOT NULL CHECK (char_length(action) BETWEEN 3 AND 100),
  resource_type text NOT NULL CHECK (char_length(resource_type) BETWEEN 2 AND 100),
  resource_id uuid,
  outcome text NOT NULL CHECK (outcome IN ('success', 'denied', 'failure')),
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  occurred_at timestamptz NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION app.enforce_finance_tenant_consistency()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE related_tenant uuid;
BEGIN
  IF TG_TABLE_NAME = 'invoice' THEN SELECT tenant_id INTO related_tenant FROM app.student WHERE id = NEW.student_id;
  ELSIF TG_TABLE_NAME = 'invoice_line' THEN SELECT tenant_id INTO related_tenant FROM app.invoice WHERE id = NEW.invoice_id;
  ELSIF TG_TABLE_NAME = 'payment' THEN SELECT tenant_id INTO related_tenant FROM app.invoice WHERE id = NEW.invoice_id;
  ELSIF TG_TABLE_NAME = 'receipt' THEN SELECT tenant_id INTO related_tenant FROM app.payment WHERE id = NEW.payment_id;
  END IF;
  IF related_tenant IS NOT NULL AND related_tenant IS DISTINCT FROM NEW.tenant_id THEN RAISE EXCEPTION 'financial relation tenant mismatch'; END IF;
  IF TG_TABLE_NAME = 'refund' THEN
    SELECT tenant_id INTO related_tenant FROM app.payment WHERE id = NEW.payment_id;
    IF related_tenant IS DISTINCT FROM NEW.tenant_id THEN RAISE EXCEPTION 'payment tenant mismatch'; END IF;
  END IF;
  RETURN NEW;
END; $$;

DO $$ DECLARE t text; BEGIN
  FOREACH t IN ARRAY ARRAY['fee', 'invoice', 'invoice_line', 'payment', 'receipt', 'refund', 'audit_event'] LOOP
    EXECUTE format('ALTER TABLE app.%I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('ALTER TABLE app.%I FORCE ROW LEVEL SECURITY', t);
    EXECUTE format('CREATE POLICY %I ON app.%I USING (tenant_id = app.current_tenant_id()) WITH CHECK (tenant_id = app.current_tenant_id())', t || '_tenant_isolation', t);
  END LOOP;
END $$;

DO $$ DECLARE t text; BEGIN
  FOREACH t IN ARRAY ARRAY['invoice', 'payment', 'receipt', 'refund'] LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS %I ON app.%I', t || '_tenant_consistency', t);
    EXECUTE format('CREATE TRIGGER %I BEFORE INSERT OR UPDATE ON app.%I FOR EACH ROW EXECUTE FUNCTION app.enforce_finance_tenant_consistency()', t || '_tenant_consistency', t);
  END LOOP;
END $$;

DO $$ DECLARE t text; BEGIN
  FOREACH t IN ARRAY ARRAY['fee', 'invoice', 'refund'] LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS %I ON app.%I', t || '_touch_updated_at', t);
    EXECUTE format('CREATE TRIGGER %I BEFORE UPDATE ON app.%I FOR EACH ROW EXECUTE FUNCTION app.touch_updated_at()', t || '_touch_updated_at', t);
  END LOOP;
END $$;
