# Phase 2 — Vérification sécurité

## Livré

- schéma tenant, memberships, rôles, permissions atomiques et affectation des rôles ;
- politiques PostgreSQL RLS forcées pour toutes les tables à portée tenant ;
- transaction serveur qui définit le tenant avec `SET LOCAL` paramétré ;
- Better Auth auto-hébergé, sessions sécurisées, mots de passe et MFA TOTP avec codes de secours et verrouillage après échecs ;
- tests unitaires négatifs d'autorisation inter-établissements.
- test d'intégration PostgreSQL RLS exécuté avec succès le 6 novembre 2026 dans un conteneur éphémère : refus sans tenant, lecture limitée au tenant courant et écriture inter-tenant refusée.
- test d'intégration étendu au noyau scolaire : une matière créée dans un tenant est invisible depuis un autre tenant.

## À vérifier avec l'infrastructure

- migration Better Auth et migration GES-SCO sur une instance PostgreSQL de test ;
- inscription, vérification email, connexion, MFA, révocation de session et récupération de compte ;
- envoi transactionnel : la configuration échoue volontairement tant qu'un fournisseur d'email n'est pas choisi ;
- rate limiting distribué et audit persistant, qui seront ajoutés avec l'infrastructure de queue/cache et les parcours sensibles.
