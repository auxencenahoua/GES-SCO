-- Academic core. Every resource is tenant-scoped and protected by RLS.
CREATE TABLE IF NOT EXISTS app.campus (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE RESTRICT,
  name text NOT NULL CHECK (char_length(name) BETWEEN 2 AND 150),
  address text,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'archived')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, name)
);

CREATE TABLE IF NOT EXISTS app.academic_year (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE RESTRICT,
  name text NOT NULL CHECK (char_length(name) BETWEEN 4 AND 50),
  starts_on date NOT NULL,
  ends_on date NOT NULL,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'closed', 'archived')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (ends_on > starts_on),
  UNIQUE (tenant_id, name)
);

CREATE TABLE IF NOT EXISTS app.guardian (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE RESTRICT,
  first_name text NOT NULL CHECK (char_length(first_name) BETWEEN 1 AND 100),
  last_name text NOT NULL CHECK (char_length(last_name) BETWEEN 1 AND 100),
  email_normalized text,
  phone_e164 text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (email_normalized IS NOT NULL OR phone_e164 IS NOT NULL)
);

CREATE UNIQUE INDEX IF NOT EXISTS guardian_email_per_tenant ON app.guardian (tenant_id, email_normalized) WHERE email_normalized IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS guardian_phone_per_tenant ON app.guardian (tenant_id, phone_e164) WHERE phone_e164 IS NOT NULL;

CREATE TABLE IF NOT EXISTS app.student (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE RESTRICT,
  student_number text NOT NULL CHECK (char_length(student_number) BETWEEN 1 AND 50),
  first_name text NOT NULL CHECK (char_length(first_name) BETWEEN 1 AND 100),
  last_name text NOT NULL CHECK (char_length(last_name) BETWEEN 1 AND 100),
  birth_date date,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'archived', 'transferred', 'graduated')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, student_number)
);

CREATE TABLE IF NOT EXISTS app.guardian_student (
  guardian_id uuid NOT NULL REFERENCES app.guardian(id) ON DELETE RESTRICT,
  student_id uuid NOT NULL REFERENCES app.student(id) ON DELETE RESTRICT,
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE RESTRICT,
  relationship text NOT NULL CHECK (char_length(relationship) BETWEEN 2 AND 50),
  is_legal_guardian boolean NOT NULL DEFAULT false,
  receives_communications boolean NOT NULL DEFAULT true,
  PRIMARY KEY (guardian_id, student_id)
);

CREATE TABLE IF NOT EXISTS app.staff (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE RESTRICT,
  staff_number text NOT NULL CHECK (char_length(staff_number) BETWEEN 1 AND 50),
  first_name text NOT NULL,
  last_name text NOT NULL,
  staff_type text NOT NULL CHECK (staff_type IN ('teacher', 'administration', 'finance', 'life_school', 'support')),
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'archived')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, staff_number)
);

CREATE TABLE IF NOT EXISTS app.class (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE RESTRICT,
  campus_id uuid REFERENCES app.campus(id) ON DELETE RESTRICT,
  academic_year_id uuid NOT NULL REFERENCES app.academic_year(id) ON DELETE RESTRICT,
  code text NOT NULL CHECK (char_length(code) BETWEEN 1 AND 50),
  name text NOT NULL CHECK (char_length(name) BETWEEN 2 AND 100),
  capacity integer CHECK (capacity IS NULL OR capacity > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, academic_year_id, code)
);

CREATE TABLE IF NOT EXISTS app.subject (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE RESTRICT,
  code text NOT NULL CHECK (char_length(code) BETWEEN 1 AND 30),
  name text NOT NULL CHECK (char_length(name) BETWEEN 2 AND 100),
  coefficient numeric(5,2) NOT NULL DEFAULT 1 CHECK (coefficient > 0 AND coefficient <= 100),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, code)
);

CREATE TABLE IF NOT EXISTS app.enrollment (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE RESTRICT,
  student_id uuid NOT NULL REFERENCES app.student(id) ON DELETE RESTRICT,
  class_id uuid NOT NULL REFERENCES app.class(id) ON DELETE RESTRICT,
  academic_year_id uuid NOT NULL REFERENCES app.academic_year(id) ON DELETE RESTRICT,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('pending', 'active', 'withdrawn', 'completed')),
  enrolled_at timestamptz NOT NULL DEFAULT now(),
  ended_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (ended_at IS NULL OR ended_at >= enrolled_at),
  UNIQUE (tenant_id, student_id, academic_year_id)
);

CREATE OR REPLACE FUNCTION app.enforce_tenant_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  related_tenant uuid;
BEGIN
  IF TG_TABLE_NAME = 'guardian_student' THEN
    SELECT tenant_id INTO related_tenant FROM app.guardian WHERE id = NEW.guardian_id;
    IF related_tenant IS DISTINCT FROM NEW.tenant_id THEN RAISE EXCEPTION 'guardian tenant mismatch'; END IF;
    SELECT tenant_id INTO related_tenant FROM app.student WHERE id = NEW.student_id;
    IF related_tenant IS DISTINCT FROM NEW.tenant_id THEN RAISE EXCEPTION 'student tenant mismatch'; END IF;
  ELSIF TG_TABLE_NAME = 'enrollment' THEN
    SELECT tenant_id INTO related_tenant FROM app.student WHERE id = NEW.student_id;
    IF related_tenant IS DISTINCT FROM NEW.tenant_id THEN RAISE EXCEPTION 'student tenant mismatch'; END IF;
    SELECT tenant_id INTO related_tenant FROM app.class WHERE id = NEW.class_id;
    IF related_tenant IS DISTINCT FROM NEW.tenant_id THEN RAISE EXCEPTION 'class tenant mismatch'; END IF;
    SELECT tenant_id INTO related_tenant FROM app.academic_year WHERE id = NEW.academic_year_id;
    IF related_tenant IS DISTINCT FROM NEW.tenant_id THEN RAISE EXCEPTION 'academic year tenant mismatch'; END IF;
  END IF;
  RETURN NEW;
END;
$$;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['campus', 'academic_year', 'guardian', 'student', 'guardian_student', 'staff', 'class', 'subject', 'enrollment']
  LOOP
    EXECUTE format('ALTER TABLE app.%I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('ALTER TABLE app.%I FORCE ROW LEVEL SECURITY', t);
    EXECUTE format('CREATE POLICY %I ON app.%I USING (tenant_id = app.current_tenant_id()) WITH CHECK (tenant_id = app.current_tenant_id())', t || '_tenant_isolation', t);
  END LOOP;
END;
$$;

DROP TRIGGER IF EXISTS guardian_student_tenant_consistency ON app.guardian_student;
CREATE TRIGGER guardian_student_tenant_consistency BEFORE INSERT OR UPDATE ON app.guardian_student FOR EACH ROW EXECUTE FUNCTION app.enforce_tenant_consistency();
DROP TRIGGER IF EXISTS enrollment_tenant_consistency ON app.enrollment;
CREATE TRIGGER enrollment_tenant_consistency BEFORE INSERT OR UPDATE ON app.enrollment FOR EACH ROW EXECUTE FUNCTION app.enforce_tenant_consistency();

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['campus', 'academic_year', 'guardian', 'student', 'staff', 'class', 'subject', 'enrollment']
  LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS %I ON app.%I', t || '_touch_updated_at', t);
    EXECUTE format('CREATE TRIGGER %I BEFORE UPDATE ON app.%I FOR EACH ROW EXECUTE FUNCTION app.touch_updated_at()', t || '_touch_updated_at', t);
  END LOOP;
END;
$$;
