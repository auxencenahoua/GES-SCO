import { z } from "zod";

const authEnvironmentSchema = z.object({
  BETTER_AUTH_SECRET: z
    .string()
    .min(32, "BETTER_AUTH_SECRET doit contenir au moins 32 caractères."),
  BETTER_AUTH_URL: z.string().url("BETTER_AUTH_URL doit être une URL absolue."),
});

export function getAuthEnvironment() {
  return authEnvironmentSchema.parse({
    BETTER_AUTH_SECRET: process.env.BETTER_AUTH_SECRET,
    BETTER_AUTH_URL: process.env.BETTER_AUTH_URL,
  });
}
