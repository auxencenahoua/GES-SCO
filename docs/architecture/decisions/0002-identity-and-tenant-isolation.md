# ADR 0002 — Identité et isolation multi-établissements

## Décision

GES-SCO utilisera Better Auth auto-hébergé avec PostgreSQL et MFA TOTP. Ce choix respecte l'exigence MFA des comptes privilégiés ; il évite de dépendre d'un service d'authentification géré dont le MFA n'est pas actuellement disponible.

Les données métier vivront dans le schéma `app`. L'identité est isolée dans le schéma `auth`. Chaque table métier doit porter `tenant_id`; PostgreSQL RLS est activé et forcé sur les tables multi-tenant.

## Règle de connexion

Le rôle applicatif ne doit jamais posséder les tables ni avoir le privilège `BYPASSRLS`. Toute opération métier se déroule dans une transaction et définit `app.tenant_id` avec `SET LOCAL` via une requête paramétrée. Le tenant n'est jamais lu depuis un paramètre HTTP.

## Conséquences

- Les migrations doivent utiliser `DATABASE_URL_UNPOOLED`.
- L'application utilise `DATABASE_URL` (poolée) uniquement côté serveur.
- Un fournisseur d'email transactionnel, la région d'hébergement et le processus de récupération de compte restent à configurer avant activation de l'inscription publique.
- Les politiques RLS doivent disposer de tests d'intégration contre une instance PostgreSQL réelle avant mise en production.
