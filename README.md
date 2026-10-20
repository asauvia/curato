# Curato

Curato is a multi-app commerce platform by ASAUViA. It has a customer storefront, an admin console, a vendor (seller) portal, and a reseller system, all served by one Node.js API.

Support: support@asauvia.com

## Repository layout

```
curato-ecom/        Customer storefront            (Flutter)
curato-admin/       Admin console                  (Flutter)
curato-vendor/      Vendor portal                  (Flutter)
curato-reseller/    Reseller panel                 (React, Vite, TypeScript)
user-reseller/      Storefront for reseller links  (React, Vite, TypeScript)
curato_backend/     REST API, realtime, jobs       (Node.js, Express, MongoDB)
```

| App | What it does | Stack |
|---|---|---|
| `curato-ecom` | Customer storefront: browse, cart, checkout, orders | Flutter |
| `curato-admin` | Admin console: vendors, orders, payouts, banners, settings | Flutter |
| `curato-vendor` | Vendor portal: products, orders, payouts, analytics | Flutter |
| `curato-reseller` | Reseller panel: catalog, markups, referral links, withdrawals | React, Vite, TypeScript |
| `user-reseller` | Storefront for reseller collections and shared links | React, Vite, TypeScript |
| `curato_backend` | REST API, realtime updates (Socket.io), background jobs | Node.js, Express, MongoDB |

## Integrations

The backend connects to MongoDB (Mongoose), Firebase Authentication (Google sign-in), ImageKit (image storage), Cashfree (online payments), Delhivery (shipping), WhatsApp and SMTP email (order and OTP messages), and OpenAI (product description generation).

## Requirements

- Node.js and npm (no version is pinned in the repo)
- A MongoDB instance
- Flutter 3.41.6 for the Flutter apps (pinned in each app's `.fvmrc`)

## Running locally

### Backend (`curato_backend`)

```bash
cd curato_backend
cp deploy/backend.env.example .env   # then fill in the values
npm install
npm run dev                          # or: npm start
```

Other scripts: `npm run seed` loads sample products, and `node seedAdmin.js` creates or updates the admin account.

The server reads these variables from `.env`:

- Core: `PORT`, `NODE_ENV`, `MONGO_URI`, `JWT_SECRET`, `BACKEND_URL`, `REFERRAL_DOMAIN`
- Images: `IMAGEKIT_PUBLIC_KEY`, `IMAGEKIT_PRIVATE_KEY`, `IMAGEKIT_URL_ENDPOINT`
- Firebase: `FIREBASE_API_KEY`, `FIREBASE_AUTH_DOMAIN`, `FIREBASE_PROJECT_ID`, `FIREBASE_STORAGE_BUCKET`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_APP_ID`, `FIREBASE_MEASUREMENT_ID`, `FIREBASE_CLIENT_EMAIL`, `FIREBASE_PRIVATE_KEY`
- Email: `EMAIL_HOST`, `EMAIL_PORT`, `EMAIL_USER`, `EMAIL_PASS`
- Payments: `CASHFREE_APP_ID`, `CASHFREE_SECRET_KEY`, `CASHFREE_ENV`, `PAYMENTGATEWAY_KEY`, `SALT`
- Shipping and AI: `DELHIVERY_TOKEN`, `OPENAI_API_KEY`
- Admin seed: `SEED_ADMIN_EMAIL`, `SEED_ADMIN_PASSWORD` (the admin account is created or updated on boot when both are set)

### Reseller panel (`curato-reseller`) and storefront (`user-reseller`)

```bash
cd curato-reseller        # or: cd user-reseller
npm install
npm run dev
npm run build
```

`curato-reseller` also has `npm run typecheck`. `user-reseller` also has `npm run lint`.

### Flutter apps (`curato-ecom`, `curato-admin`, `curato-vendor`)

```bash
cd curato-ecom            # or curato-admin / curato-vendor
flutter pub get
flutter run -d chrome
flutter analyze
```

The storefront reads its Firebase web configuration from a local `.env` file, which is git-ignored. Copy the template and fill in the values for your Firebase project:

```bash
cp curato-ecom/.env.example curato-ecom/.env
flutter run -d chrome --dart-define-from-file=.env
```

Without `FIREBASE_API_KEY`, the storefront starts and logs a message, but Firebase sign-in will not work.

`pubspec.lock` in these apps is out of date with `pubspec.yaml`. `flutter pub get` will update it.

## Security

- `.env` files are git-ignored. Never commit real values. Only `deploy/backend.env.example` is tracked, and it contains placeholders.
- No API keys, passwords or server addresses are stored in the source. Credentials come from environment variables or build-time defines.

## Known gaps before production

- Firebase: Curato needs its own Firebase project. Create it, then fill in `curato-ecom/.env` (from `.env.example`) and the Firebase values in the backend `.env`. The previous Firebase project is no longer referenced in the code.
- `curato-ecom/web/index.html` lists social-media links that still use the previous brand's handles. Update them to the real accounts or remove them.
- Android and iOS bundle IDs are `com.asauvia.curato.user`, `com.asauvia.curato.admin` and `com.asauvia.curato.vendor`. Existing installs of the previous app will not update to these IDs.
- There is no automated test suite. The backend `npm test` script is a placeholder, and the Flutter apps still contain the default counter widget test, which does not match the apps.

## Deployment

The backend deploy files are in `curato_backend/deploy/`:

- `install-vps.sh` sets up the server (nginx and pm2)
- `ecosystem.config.cjs` runs the API as the pm2 app `curato-api`
- `nginx-curato-ip.conf` is the nginx site
- `build-web.sh` builds the web apps

If a server previously ran the old name, stop the old pm2 process (`pm2 delete <old-name>`) and remove the old nginx site before you deploy.

## Brand

Product: Curato. Company: ASAUViA.
