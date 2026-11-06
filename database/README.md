# Migrations PostgreSQL

1. Générer les tables Better Auth dans le schéma `auth` avec la configuration de `src/lib/auth/auth.ts` : `npx auth@1.7.18 generate` ou la commande de migration Better Auth correspondante.
2. Vérifier le SQL généré, puis l'appliquer avec `DATABASE_URL_UNPOOLED` ; ne jamais migrer avec la connexion poolée de l'application.
3. Appliquer ensuite [0001_identity_and_tenants.sql](./migrations/0001_identity_and_tenants.sql).

La migration active et force RLS sur les tables multi-tenant. Elle doit être vérifiée avec un rôle applicatif non-propriétaire et sans `BYPASSRLS`. Les tests d'intégration RLS nécessitent une base PostgreSQL réelle configurée dans un environnement de test ; ils ne peuvent pas être simulés correctement sans celle-ci.
