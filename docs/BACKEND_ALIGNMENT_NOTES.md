# RxEdge Backend & Mobile Alignment Summary (`D:\Backend\rxedge` ↔ `d:\Flutter\rxedge`)

All backend and mobile alignment items listed in earlier notes have now been implemented across both repositories and configured for the live server URL **`http://rxedge.agro-plus.net/`**.

---

## 1. Backend Enhancements Applied in `D:\Backend\rxedge`
1. **Health Endpoint (`src/index.routes.js`)**
   - Registered `GET /api/v1/health` alongside `GET /health` with shared payload metadata (`status`, `version`, `buildNumber`, `minSupportedVersion`, `maintenanceMode`, `uptime`, `timestamp`).
2. **Real Media Assets & Static Fallback (`public_assets/`, `uploads/`, `Dockerfile`, `src/index.routes.js`)**
   - Added real PNG product box shots (`cardura_xl.png`, `atorvacare.png`, `glucobalance.png`), slide/visual images, thumbnails, and `cardura_monograph.pdf`.
   - Added `express.static(path.resolve("./public_assets"))` fallback under `/uploads` and copied `./public_assets` into the Docker runtime image so seeded assets remain accessible even when `/app/uploads` is a Docker named volume.
3. **Arabic-First Defaults & Bilingual Seed (`prisma/schema.prisma`, `src/Middlewares/i18n.js`, `prisma/seed.js`)**
   - Changed `User.language` Prisma default to `"ar"`.
   - Updated `i18n` middleware priority: explicit `Accept-Language` header → `req.user?.language` → `"ar"`.
   - Rewrote `prisma/seed.js` idempotently with 3 products, Arabic + English lessons, competitors, Objections of the Month, E-Detailing slides + PDF, 2 quizzes, an active Monthly Challenge with 3 leaderboard reps (`rep@rxedge.com`, `rep2@rxedge.com`, `rep3@rxedge.com`), and bilingual notifications.
4. **CORS & Live URL (`src/app.controller.js`)**
   - Enabled `http://rxedge.agro-plus.net`, `https://rxedge.agro-plus.net`, and `^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$` in allowed CORS origins.
5. **User Preferences, Search, Dashboard & Challenge Rank**
   - Added `PATCH /api/v1/auth/me/preferences` (`language: "ar" | "en"`) with Redis user cache invalidation (`src/modules/Auth/*`, `PERMISSIONS.PROFILE.UPDATE` granted to `MEDICAL_REP`, `SUPERVISOR`, and `MARKETING_ADMIN`).
   - Added `GET /api/v1/search?q=<query>` (`src/modules/Search/*`) searching products, lessons, materials, and competitors in `req.lang`.
   - Updated `Gamification` (`getActiveChallenge`) and `Dashboard` (`getHomeDashboard`) to compute real `userRank`, `totalParticipants`, `lessonProgress`, `therapeuticAreaName`, and `version` / `updatedAt`.
6. **Live DB Schema Push & Seed on Deploy (`.github/workflows/deploy.yml`)**
   - Fixed the deployment script so when `prisma/migrations` is absent it runs `npx prisma db push` and then `npm run seed` automatically.

---

## 2. Mobile Enhancements Applied in `d:\Flutter\rxedge`
1. **Live Server Configuration (`lib/core/config/env_config.dart`, `lib/main.dart`, `lib/main_prod.dart`, `lib/main_staging.dart`)**
   - Added `EnvConfig.liveServerBaseUrl = 'http://rxedge.agro-plus.net/api/v1'` and pointed default `main.dart`, `main_prod.dart`, and `main_staging.dart` to `EnvConfig.defaultLiveBaseUrl` (while `lib/main_dev.dart` keeps `defaultDevBaseUrl` and `--dart-define=API_BASE_URL=...` still overrides any build).
2. **Android Cleartext HTTP Support (`android/app/src/main/AndroidManifest.xml`)**
   - Added `android:usesCleartextTraffic="true"` on `<application>` so `http://rxedge.agro-plus.net/` works on Android 9+ devices.
3. **Profile Language Sync & Global Search Endpoint Integration**
   - Wired `ProfileScreen` language toggle → `ProfileRepository.updateLanguagePreference()` → `PATCH /api/v1/auth/me/preferences`.
   - Wired `SearchRepositoryImpl` → `GET /api/v1/search?q=...` with automatic local repository aggregation fallback when offline.

---

## 3. Deployment Note for `http://rxedge.agro-plus.net/`
Live inspection of `http://rxedge.agro-plus.net/` showed Express running (`/health` returned `200 OK`), while PostgreSQL tables were not yet created (`The table public.User does not exist`). Pushing the updated `D:\Backend\rxedge` changes to `origin main` will trigger `.github/workflows/deploy.yml` to rebuild the container, run `prisma db push`, and execute `npm run seed`.
