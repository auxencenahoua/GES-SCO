# GES-SCO

Plateforme SaaS de gestion scolaire multi-établissements, conçue d'abord pour les établissements ivoiriens et extensible aux autres marchés africains.

## État actuel

Les phases Fondations et Identité & multi-tenant sont en cours de livraison. Les modules métier ne sont pas encore exposés : l'isolation des établissements et les contrôles d'accès doivent être validés sur PostgreSQL avant la création de données scolaires ou financières.

Le parcours d'onboarding est préparé à l'adresse `/onboarding`. Ses étapes, ses transitions et son brouillon persistent côté serveur dès que la base PostgreSQL est validée ; l'activation reste délibérément bloquée jusque-là.

## Démarrage local

1. Installer Node.js 22.18 ou plus récent et PostgreSQL.
2. Copier `.env.example` vers `.env.local`, puis définir les variables avec de vraies valeurs locales.
3. Installer les dépendances avec `npm ci`.
4. Lancer l'interface avec `npm run dev`.

Ne mettez jamais de secrets dans Git. `BETTER_AUTH_SECRET` doit être aléatoire et contenir au moins 32 caractères.

## Base de données et sécurité

L'authentification est auto-hébergée avec Better Auth et MFA TOTP. Les comptes privilégiés devront obligatoirement activer MFA avant toute mise en production.

Les données métier sont isolées par `tenant_id` dans PostgreSQL. Chaque transaction applicative installe le tenant validé côté serveur avec `SET LOCAL`, et les politiques RLS forcent ce cloisonnement en défense supplémentaire. Consultez [les instructions de migration](./database/README.md) et la [décision d'architecture](./docs/architecture/decisions/0002-identity-and-tenant-isolation.md) avant d'appliquer un schéma.

L'inscription publique est bloquée tant qu'un fournisseur d'email transactionnel n'a pas été configuré : c'est un comportement de sécurité volontaire.

## Vérifications

```text
npm run format:check
npm run lint
npm run typecheck
npm test
npm run build
```

La CI exécute ces commandes à chaque push et pull request. Les tests RLS nécessitent en plus une base PostgreSQL réelle dédiée aux tests ; leur protocole est décrit dans [phase-2-verification.md](./docs/security/phase-2-verification.md).

Les états et contraintes de l'onboarding sont couverts par les tests du domaine. La migration associée est [0002_onboarding.sql](./database/migrations/0002_onboarding.sql).
