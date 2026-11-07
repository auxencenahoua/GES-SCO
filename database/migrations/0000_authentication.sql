-- Better Auth schema generated for the configured Postgres adapter and TOTP plugin.
CREATE SCHEMA IF NOT EXISTS auth;

ALTER TABLE auth."user" ADD COLUMN IF NOT EXISTS name text;
ALTER TABLE auth."user" ADD COLUMN IF NOT EXISTS email text;
ALTER TABLE auth."user" ADD COLUMN IF NOT EXISTS "emailVerified" boolean DEFAULT false;
ALTER TABLE auth."user" ADD COLUMN IF NOT EXISTS image text;
ALTER TABLE auth."user" ADD COLUMN IF NOT EXISTS "createdAt" timestamptz DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE auth."user" ADD COLUMN IF NOT EXISTS "updatedAt" timestamptz DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE auth."user" ADD COLUMN IF NOT EXISTS "twoFactorEnabled" boolean DEFAULT false;
ALTER TABLE auth."user" ALTER COLUMN name SET NOT NULL;
ALTER TABLE auth."user" ALTER COLUMN email SET NOT NULL;
ALTER TABLE auth."user" ALTER COLUMN "emailVerified" SET NOT NULL;
ALTER TABLE auth."user" ALTER COLUMN "createdAt" SET NOT NULL;
ALTER TABLE auth."user" ALTER COLUMN "updatedAt" SET NOT NULL;

CREATE TABLE IF NOT EXISTS auth.session (id text PRIMARY KEY, "expiresAt" timestamptz NOT NULL, token text NOT NULL UNIQUE, "createdAt" timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL, "updatedAt" timestamptz NOT NULL, "ipAddress" text, "userAgent" text, "userId" text NOT NULL REFERENCES auth."user" (id) ON DELETE CASCADE);
CREATE TABLE IF NOT EXISTS auth.account (id text PRIMARY KEY, "accountId" text NOT NULL, "providerId" text NOT NULL, "userId" text NOT NULL REFERENCES auth."user" (id) ON DELETE CASCADE, "accessToken" text, "refreshToken" text, "idToken" text, "accessTokenExpiresAt" timestamptz, "refreshTokenExpiresAt" timestamptz, scope text, password text, "createdAt" timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL, "updatedAt" timestamptz NOT NULL);
CREATE TABLE IF NOT EXISTS auth.verification (id text PRIMARY KEY, identifier text NOT NULL, value text NOT NULL, "expiresAt" timestamptz NOT NULL, "createdAt" timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL, "updatedAt" timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL);
CREATE TABLE IF NOT EXISTS auth."twoFactor" (id text PRIMARY KEY, secret text NOT NULL, "backupCodes" text NOT NULL, "userId" text NOT NULL REFERENCES auth."user" (id) ON DELETE CASCADE, verified boolean, "failedVerificationCount" integer, "lockedUntil" timestamptz);

CREATE UNIQUE INDEX IF NOT EXISTS user_email_uidx ON auth."user" (email);
CREATE INDEX IF NOT EXISTS session_user_id_idx ON auth.session ("userId");
CREATE INDEX IF NOT EXISTS account_user_id_idx ON auth.account ("userId");
CREATE INDEX IF NOT EXISTS verification_identifier_idx ON auth.verification (identifier);
CREATE INDEX IF NOT EXISTS two_factor_secret_idx ON auth."twoFactor" (secret);
CREATE INDEX IF NOT EXISTS two_factor_user_id_idx ON auth."twoFactor" ("userId");
