# Phase 2 — Vérification sécurité

## Livré

- schéma tenant, memberships, rôles, permissions atomiques et affectation des rôles ;
- politiques PostgreSQL RLS forcées pour toutes les tables à portée tenant ;
- transaction serveur qui définit le tenant avec `SET LOCAL` paramétré ;
- Better Auth auto-hébergé, sessions sécurisées, mots de passe et MFA TOTP avec codes de secours et verrouillage après échecs ;
- tests unitaires négatifs d'autorisation inter-établissements.

## À vérifier avec l'infrastructure

- migration Better Auth et migration GES-SCO sur une instance PostgreSQL de test ;
- test RLS avec deux tenants, un rôle applicatif non-propriétaire et des transactions séparées ;
- inscription, vérification email, connexion, MFA, révocation de session et récupération de compte ;
- envoi transactionnel : la configuration échoue volontairement tant qu'un fournisseur d'email n'est pas choisi ;
- rate limiting distribué et audit persistant, qui seront ajoutés avec l'infrastructure de queue/cache et les parcours sensibles.
