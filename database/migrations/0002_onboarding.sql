-- Requires 0001_identity_and_tenants.sql and the Better Auth schema.
CREATE TABLE IF NOT EXISTS app.onboarding_draft (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL UNIQUE REFERENCES app.tenant(id) ON DELETE RESTRICT,
  owner_user_id text NOT NULL REFERENCES auth."user"(id) ON DELETE RESTRICT,
  current_step smallint NOT NULL DEFAULT 1 CHECK (current_step BETWEEN 1 AND 8),
  completed_steps smallint[] NOT NULL DEFAULT '{}',
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  status text NOT NULL DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'ready_for_activation', 'activated', 'cancelled')),
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE app.onboarding_draft ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.onboarding_draft FORCE ROW LEVEL SECURITY;

CREATE POLICY onboarding_draft_tenant_isolation ON app.onboarding_draft
  USING (tenant_id = app.current_tenant_id())
  WITH CHECK (tenant_id = app.current_tenant_id());

CREATE OR REPLACE FUNCTION app.touch_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS onboarding_draft_touch_updated_at ON app.onboarding_draft;
CREATE TRIGGER onboarding_draft_touch_updated_at
  BEFORE UPDATE ON app.onboarding_draft
  FOR EACH ROW EXECUTE FUNCTION app.touch_updated_at();
