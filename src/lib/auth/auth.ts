import { betterAuth } from "better-auth";
import { twoFactor } from "better-auth/plugins";
import { PostgresDialect } from "kysely";
import { getDatabasePool } from "@/lib/database/pool";
import { getAuthEnvironment } from "./config";

function createAuth() {
  const environment = getAuthEnvironment();

  return betterAuth({
    appName: "GES-SCO",
    baseURL: environment.BETTER_AUTH_URL,
    secret: environment.BETTER_AUTH_SECRET,
    database: {
      dialect: new PostgresDialect({ pool: getDatabasePool() }),
      type: "postgres",
      schemaName: "auth",
    },
    advanced: {
      database: { joins: true },
      defaultCookieAttributes: {
        httpOnly: true,
        sameSite: "lax",
        secure: environment.BETTER_AUTH_URL.startsWith("https://"),
      },
    },
    emailAndPassword: {
      enabled: true,
      requireEmailVerification: true,
    },
    emailVerification: {
      sendVerificationEmail: async () => {
        // Public sign-up remains unavailable until a transactional mail provider
        // is configured. Failing closed prevents unverified accounts.
        throw new Error("La vérification d’email n’est pas encore configurée.");
      },
    },
    session: {
      expiresIn: 60 * 60 * 8,
      updateAge: 60 * 15,
    },
    plugins: [
      twoFactor({
        issuer: "GES-SCO",
        totpOptions: { period: 30, digits: 6 },
        backupCodeOptions: { amount: 10, length: 10 },
        accountLockout: {
          enabled: true,
          maxFailedAttempts: 5,
          durationSeconds: 15 * 60,
        },
      }),
    ],
  });
}

let authInstance: ReturnType<typeof createAuth> | undefined;

/** Creates the server-only Better Auth instance on first authenticated request. */
export function getAuth(): ReturnType<typeof createAuth> {
  authInstance ??= createAuth();
  return authInstance;
}
