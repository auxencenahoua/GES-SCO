# Déploiement

## Variables obligatoires

- `DATABASE_URL` : URL Neon poolée pour le trafic applicatif.
- `DATABASE_URL_UNPOOLED` : URL Neon directe, sans suffixe `-pooler`, utilisée par les migrations.
- `BETTER_AUTH_SECRET` : secret aléatoire d’au moins 32 caractères.
- `BETTER_AUTH_URL` : URL publique exacte de l’application.

## Prévisualisation locale

1. Copier `.env.example` vers `.env.local` et renseigner les valeurs locales.
2. Lancer `npm run db:migrate` avec `DATABASE_URL_UNPOOLED`.
3. Démarrer `npm run dev -- --port 3001`.
4. Vérifier `GET /api/health` avant de tester l’interface.

## Vercel / production

Le fichier `vercel.json` exécute `npm run db:migrate && npm run build`. Déclarer les quatre variables dans l’environnement Preview et Production de Vercel. Les migrations utilisent exclusivement l’URL directe ; l’application conserve l’URL poolée.

Après déploiement, vérifier `/api/health`, `/api/auth/get-session` et le workflow d’uptime GitHub avec le secret `APP_HEALTH_URL`.
