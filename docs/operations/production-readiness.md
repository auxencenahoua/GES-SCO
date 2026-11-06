# Fiabilité et exploitation

## Implémenté dans le dépôt

- RLS PostgreSQL et tests inter-tenant ;
- clés d’idempotence pour les paiements ;
- pagination bornée à 100 éléments et index de listes fréquentes ;
- limites de poids (10 Mo), liste blanche MIME et compression WebP navigateur ;
- timeout et reprise limitée pour les appels sortants ;
- limite locale de requêtes et endpoint de santé `GET /api/health` ;
- plafonds d’appels et de coûts par fournisseur (`provider-budget`) ;
- verrou anti-double soumission (`action-lock`) ;
- cache TTL pour les données stables et journalisation structurée des erreurs ;
- écrans de chargement et erreur avec reprise ;
- script de test concurrent `npm run test:load` et workflow d’uptime planifié.

## À configurer avant production

- Remplacer la limite locale par Redis/Upstash afin qu’elle soit partagée entre toutes les instances.
- Configurer budgets, quotas et alertes de chaque fournisseur (paiement, SMS, email, WhatsApp, stockage, IA).
- Connecter `/api/health` à un moniteur externe avec alerte SMS/email et centraliser les erreurs dans Sentry ou équivalent.
- Configurer S3 privé + antivirus avant de publier les endpoints d’upload ; une validation MIME navigateur ne suffit jamais seule.
- Exécuter `npm run test:load` contre l’URL déployée avec des valeurs de concurrence représentatives.
- Planifier un exercice trimestriel documenté de restauration de sauvegarde ; voir [backup-restore.md](./backup-restore.md).
