-- Run with a migration role over a direct PostgreSQL connection.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS app;

CREATE TABLE IF NOT EXISTS app.tenant (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  legal_name text NOT NULL CHECK (char_length(legal_name) BETWEEN 2 AND 200),
  display_name text NOT NULL CHECK (char_length(display_name) BETWEEN 2 AND 200),
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'suspended', 'archived')),
  locale text NOT NULL DEFAULT 'fr-CI',
  timezone text NOT NULL DEFAULT 'Africa/Abidjan',
  currency char(3) NOT NULL DEFAULT 'XOF',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS app.membership (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE RESTRICT,
  user_id text NOT NULL REFERENCES auth."user"(id) ON DELETE RESTRICT,
  status text NOT NULL DEFAULT 'invited' CHECK (status IN ('invited', 'active', 'suspended', 'revoked')),
  created_at timestamptz NOT NULL DEFAULT now(),
  joined_at timestamptz,
  UNIQUE (tenant_id, user_id)
);

CREATE TABLE IF NOT EXISTS app.role (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE RESTRICT,
  code text NOT NULL CHECK (code ~ '^[a-z][a-z0-9_.-]{1,63}$'),
  name text NOT NULL CHECK (char_length(name) BETWEEN 2 AND 100),
  is_system boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, code)
);

CREATE TABLE IF NOT EXISTS app.permission (
  code text PRIMARY KEY CHECK (code ~ '^[a-z][a-z0-9_.-]{1,95}$'),
  description text NOT NULL
);

CREATE TABLE IF NOT EXISTS app.role_permission (
  role_id uuid NOT NULL REFERENCES app.role(id) ON DELETE CASCADE,
  permission_code text NOT NULL REFERENCES app.permission(code) ON DELETE RESTRICT,
  PRIMARY KEY (role_id, permission_code)
);

CREATE TABLE IF NOT EXISTS app.membership_role (
  membership_id uuid NOT NULL REFERENCES app.membership(id) ON DELETE CASCADE,
  role_id uuid NOT NULL REFERENCES app.role(id) ON DELETE CASCADE,
  PRIMARY KEY (membership_id, role_id)
);

INSERT INTO app.permission (code, description) VALUES
  ('tenants.read', 'Consulter les paramètres de l’établissement'),
  ('settings.manage', 'Gérer les paramètres de l’établissement'),
  ('users.invite', 'Inviter des utilisateurs'),
  ('students.read', 'Consulter les dossiers élèves'),
  ('students.create', 'Créer des dossiers élèves'),
  ('students.update', 'Mettre à jour des dossiers élèves'),
  ('students.archive', 'Archiver des dossiers élèves'),
  ('grades.publish', 'Publier les notes'),
  ('finance.payment.create', 'Enregistrer un paiement'),
  ('finance.refund.approve', 'Approuver un remboursement'),
  ('audit.read', 'Consulter le journal d’audit')
ON CONFLICT (code) DO NOTHING;

CREATE OR REPLACE FUNCTION app.current_tenant_id()
RETURNS uuid
LANGUAGE sql
STABLE
AS $$ SELECT NULLIF(current_setting('app.tenant_id', true), '')::uuid $$;

ALTER TABLE app.tenant ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.tenant FORCE ROW LEVEL SECURITY;
ALTER TABLE app.membership ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.membership FORCE ROW LEVEL SECURITY;
ALTER TABLE app.role ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.role FORCE ROW LEVEL SECURITY;
ALTER TABLE app.role_permission ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.role_permission FORCE ROW LEVEL SECURITY;
ALTER TABLE app.membership_role ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.membership_role FORCE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON app.tenant
  USING (id = app.current_tenant_id())
  WITH CHECK (id = app.current_tenant_id());
CREATE POLICY membership_tenant_isolation ON app.membership
  USING (tenant_id = app.current_tenant_id())
  WITH CHECK (tenant_id = app.current_tenant_id());
CREATE POLICY role_tenant_isolation ON app.role
  USING (tenant_id = app.current_tenant_id())
  WITH CHECK (tenant_id = app.current_tenant_id());
CREATE POLICY role_permission_tenant_isolation ON app.role_permission
  USING (EXISTS (SELECT 1 FROM app.role r WHERE r.id = role_id AND r.tenant_id = app.current_tenant_id()))
  WITH CHECK (EXISTS (SELECT 1 FROM app.role r WHERE r.id = role_id AND r.tenant_id = app.current_tenant_id()));
CREATE POLICY membership_role_tenant_isolation ON app.membership_role
  USING (EXISTS (SELECT 1 FROM app.membership m WHERE m.id = membership_id AND m.tenant_id = app.current_tenant_id()))
  WITH CHECK (EXISTS (SELECT 1 FROM app.membership m WHERE m.id = membership_id AND m.tenant_id = app.current_tenant_id()));
