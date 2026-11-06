# ADR 0001 — Fondation applicative

## Décision

Utiliser Next.js avec TypeScript strict et App Router, dans un monolithe modulaire. PostgreSQL est la base relationnelle prévue ; la sélection de l'hébergeur et de la région reste une décision d'exploitation.

## Conséquences

- les règles métier ne vivront pas dans les composants React ;
- les accès sensibles seront toujours contrôlés côté serveur ;
- une queue de tâches et un stockage objet privé seront introduits avant les imports, exports et documents ;
- le déploiement production reste bloqué jusqu'à validation de la résidence des données, des sauvegardes et de la conformité applicable en Côte d'Ivoire.
