# Exercice de restauration

La restauration doit être vérifiée sur une base isolée, jamais directement sur la production.

1. Exporter la base avec `pg_dump --format=custom --file=backup.dump "$DATABASE_URL_DIRECT"`.
2. Créer une base temporaire et restaurer avec `pg_restore --clean --if-exists --dbname="$RESTORE_DATABASE_URL" backup.dump`.
3. Exécuter les migrations et `npm run test:integration` avec `DATABASE_TEST_URL` pointant vers la base restaurée.
4. Vérifier les contrôles de santé et supprimer la base temporaire après archivage de la preuve (date, durée, taille, résultat).

Cet exercice doit être réalisé au moins chaque trimestre et après toute modification majeure du schéma.
