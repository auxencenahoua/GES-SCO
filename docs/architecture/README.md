# Architecture GES-SCO

GES-SCO démarre comme un monolithe modulaire Next.js. Les frontières de domaine sont des contrats de code : chaque module possède ses types, ses règles métier, ses politiques d'autorisation et ses adaptateurs de persistance.

## Modules cibles

- platform : tenants, abonnements, feature flags et support encadré ;
- identity : identité, sessions, MFA, memberships et autorisation ;
- academic : élèves, responsables, personnel, structure et inscriptions ;
- pedagogy : emploi du temps, présence, évaluations et bulletins ;
- finance : frais, factures, paiements, reçus et remboursements ;
- communication : annonces, messagerie et notifications ;
- documents : modèles, fichiers privés, exports et signatures ;
- extensions : RH, bibliothèque, cantine, e-learning et inventaire.

Chaque module métier devra porter un `tenant_id`. Le contexte de tenant provient exclusivement de la session vérifiée côté serveur. PostgreSQL RLS sera ajouté avec les migrations de la phase Identité & multi-tenant ; aucune route métier ne devra contourner cette règle.
