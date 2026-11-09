# RxEdge Architecture Specification & Contract

This document defines the architectural contract for **RxEdge**, a premium internal learning and field resource platform for Medical Representatives (MRs). **Every subsequent feature built in this repository MUST strictly adhere to this contract.**

---

## 1. Core Architecture: Feature-First Clean Architecture

RxEdge follows a **pragmatic, feature-first Clean Architecture** designed for maintainability, offline capability, high testability, and strict layer decoupling.

```
lib/
  main.dart                      # Default bootstrap (Dev fallback)
  main_dev.dart                  # Development flavor bootstrap
  main_staging.dart              # Staging flavor bootstrap
  main_prod.dart                 # Production flavor bootstrap
  app/
    app.dart                     # Root MaterialApp.router & Provider bindings
    router/                      # go_router configuration & 5-tab StatefulShellRoute
    theme/                       # Design system theme bindings & extensions
    l10n/                        # Localization convenience exports & locale provider
  core/
    config/                      # FlavorConfig, EnvConfig, AppConstants
    network/                     # Dio client, AuthInterceptor, ErrorInterceptor, LoggingInterceptor, ApiEndpoints
    error/                       # Typed AppExceptions, sealed Failure, ExceptionMapper, FailureMessageMapper
    storage/                     # SecureStorageService, LocalCacheService (stale-while-revalidate), OfflineQueueService
    utils/                       # Result<T>, Debouncer, Formatters, Extensions
    widgets/                     # Shared design system components (AppButton, AppCard, etc.)
    services/                    # ConnectivityService, Logger (AppLogger), NotificationsService, FileDownloadService
  features/<feature>/
    data/
      models/                    # Data Transfer Objects (DTOs) with JSON serialization
      datasources/               # Remote & Local datasources throwing typed AppExceptions
      repositories/              # Repository implementations deciding remote vs cache
    domain/
      entities/                  # Pure Dart domain entities (ZERO Flutter/Dio/Hive imports)
      repositories/              # Abstract repository interfaces returning Future<Result<T>>
      usecases/                  # Reusable business logic units (optional for non-trivial logic)
    presentation/
      screens/                   # Dumb screens rendering AsyncValue via shared widgets
      widgets/                   # Feature-specific dumb sub-widgets (<300 lines)
      controllers/               # Riverpod AsyncNotifier / Notifier managing UI state
```

---

## 2. Strict Dependency Rules

```
┌──────────────────────────────────────────────┐
│             Presentation Layer               │
│         (Screens, Widgets, Controllers)      │
└──────────────────────┬───────────────────────┘
                       │ depends on
                       ▼
┌──────────────────────────────────────────────┐
│               Domain Layer                   │
│         (Entities, Repository Contracts)     │
└──────────────────────▲───────────────────────┘
                       │ implemented by
┌──────────────────────┴───────────────────────┐
│                 Data Layer                   │
│        (DTOs, Datasources, Repositories)     │
└──────────────────────────────────────────────┘
```

1. **Domain has ZERO framework dependencies:**
   No `flutter`, `dio`, `hive`, or UI imports are permitted in `features/<feature>/domain/`. It must remain 100% pure Dart.
2. **Features NEVER import another feature's data or presentation layer:**
   Cross-feature collaboration occurs only through domain contracts or `core/`.
3. **Data flows inward:**
   `presentation` calls `domain` (via controllers/usecases). `data` implements `domain` interfaces.

---

## 3. State Management Contract (Riverpod)

* **Controllers:** Every screen or user flow is managed by an `AsyncNotifier<T>` or `Notifier<T>` from `flutter_riverpod`.
* **Dumb Widgets:**
  * Zero business logic inside widgets.
  * Zero direct API calls (`dio.get(...)`) inside widgets.
  * Zero direct JSON parsing inside widgets.
* **AsyncValue Rendering:** Every asynchronous state is represented as `AsyncValue<T>` and rendered cleanly with:
  * **Loading:** `SkeletonBox` (designed pulse skeleton).
  * **Error:** `ErrorState` with human-readable localized message and a retry action button.
  * **Data:** The actual view component.
* **Dependency Injection:** Repositories, datasources, and services are exposed as Riverpod providers defined in the feature's data layer. They must be easily overridable in tests via `overrideWithValue(...)`.

---

## 4. Error Handling Contract

1. **Datasources throw typed `AppException`:**
   * `NetworkException`: Disconnects, timeouts, socket failures.
   * `ServerException(statusCode, message)`: 5xx and unhandled 4xx responses.
   * `UnauthorizedException`: 401 session expiry.
   * `ValidationException(fieldErrors)`: 422 field errors.
   * `CacheException`: Local read/write disk failures.
   * `NotFoundException`: 404 missing resource.
2. **Repositories catch exceptions and return `Result<T>`:**
   * Repositories convert exceptions into sealed `Failure` (`NetworkFailure`, `ServerFailure`, `UnauthorizedFailure`, `ValidationFailure`, `CacheFailure`, `NotFoundFailure`, `UnknownFailure`).
   * Repositories **never throw into the UI**. They return `Result.success(data)` or `Result.failure(failure)`.
3. **Single Failure Mapper (`FailureMessageMapper`):**
   * Converts any `Failure` into a friendly, professional localized string.
   * **Rule:** Never display raw exceptions, status codes, or stack traces in the UI.
4. **Centralized 401 Unauthorized Interception:**
   * Handled inside `AuthInterceptor`. It clears secure credentials and triggers session renewal/logout automatically.

---

## 5. Data & Offline Strategy (Stale-While-Revalidate)

RxEdge operates primarily in offline medical clinics and hospital wards:

1. **Stale-While-Revalidate Read Strategy:**
   ```
   Request Data
       │
       ├─► 1. Check Local Cache
       │        ├─► Fresh? ──► Return cached Result.success immediately
       │        └─► Stale? ──► Continue to remote fetch
       │
       ├─► 2. Fetch Remote API
       │        ├─► Success ──► Write to Local Cache ──► Return Result.success
       │        └─► Failure ──► Has stale cache?
       │                              ├─► Yes ──► Serve stale cache (fallback)
       │                              └─► No  ──► Map to Failure ──► Return Result.failure
   ```
2. **DTO Separation:**
   * DTOs (`<name>_dto.dart`) parse network JSON and handle snake_case to camelCase conversion.
   * DTOs provide explicit mappers: `toDomain()` and `fromDomain()`.
3. **Offline Write Queue (`OfflineQueueService`):**
   * Outgoing mutations (visit feedback, quiz answers) that fail while offline are enqueued with retry counters and synced automatically once reconnected.

---

## 6. Navigation Contract (go_router)

* Configured in `lib/app/router/app_router.dart`.
* Standard 5-tab `StatefulShellRoute` representing Medical Representative field workflows:
  1. **Detailing** (`/detailing`) - Interactive product presentations.
  2. **Products** (`/products`) - Monograph directory & formulary.
  3. **Modules** (`/modules`) - Micro-learning courses and quizzes.
  4. **Schedule** (`/schedule`) - Doctor itinerary and territory appointments.
  5. **Profile** (`/profile`) - Performance metrics and settings.
* Deep linking ready with named routes and parameter parsing.

---

## 7. Quality & Code Conventions

* **No Print Statements:** Use `AppLogger.d()`, `AppLogger.i()`, `AppLogger.w()`, `AppLogger.e()`.
* **No Hardcoded Tokens:** Colors (`context.rxColors`), spacing (`RxSpacing`), radii (`RxRadii`), text styles (`Theme.of(context).textTheme`) must come from design tokens.
* **No Hardcoded Strings:** User-facing strings must use ARB localizations (`context.l10n`).
* **Full RTL Directionality:** All padding must use `EdgeInsetsDirectional` and `AlignmentDirectional`.
* **File Suffixes:**
  * `_screen.dart` (UI Screen)
  * `_widget.dart` (UI Subcomponent)
  * `_controller.dart` (Riverpod Notifier)
  * `_state.dart` (Immutable UI State)
  * `_repository.dart` (Abstract Contract)
  * `_repository_impl.dart` (Data implementation)
  * `_datasource.dart` (Remote or Local Datasource)
  * `_dto.dart` (Data Transfer Object)
  * `_entity.dart` (Domain Entity)
  * `_usecase.dart` (Domain Usecase)
* **File Length:** Maximum ~300 lines per file; extract sub-widgets early.

---

## 8. "How to Add a New Feature" Checklist

When adding any feature (e.g. `auth`, `home`, `learn`, `library`, `challenges`, `feedback`, `profile`, `notifications`, `search`), follow this step-by-step procedure:

- [ ] **Step 1: Domain Entity**
  * Create `lib/features/<feature>/domain/entities/<feature>_entity.dart`.
  * Ensure pure Dart only (no Flutter, no external HTTP/database packages).
- [ ] **Step 2: Domain Repository Contract**
  * Create `lib/features/<feature>/domain/repositories/<feature>_repository.dart`.
  * Define methods returning `Future<Result<T>>` or `Stream<Result<T>>`.
- [ ] **Step 3: Data Transfer Object (DTO)**
  * Create `lib/features/<feature>/data/models/<feature>_dto.dart`.
  * Implement `fromJson`, `toJson`, `toDomain()`, and `fromDomain()`.
- [ ] **Step 4: Datasources**
  * Create `lib/features/<feature>/data/datasources/<feature>_remote_datasource.dart` (calling Dio, throwing typed `AppException`).
  * Create `lib/features/<feature>/data/datasources/<feature>_local_datasource.dart` (reading/writing to `LocalCacheService`).
- [ ] **Step 5: Repository Implementation**
  * Create `lib/features/<feature>/data/repositories/<feature>_repository_impl.dart`.
  * Implement stale-while-revalidate and map exceptions via `ExceptionMapper.map`.
  * Define and export Riverpod providers (`<feature>RepositoryProvider`).
- [ ] **Step 6: Presentation Controller**
  * Create `lib/features/<feature>/presentation/controllers/<feature>_controller.dart`.
  * Subclass `AutoDisposeAsyncNotifier<T>` to manage `AsyncValue<T>`.
- [ ] **Step 7: Presentation Screen & Widgets**
  * Create `lib/features/<feature>/presentation/screens/<feature>_screen.dart`.
  * Use `AsyncValue.when` with `SkeletonBox`, `ErrorState`, and `AppCard`.
  * Keep screens under 300 lines by extracting subcomponents into `presentation/widgets/`.
- [ ] **Step 8: Router Registration**
  * Register the screen route in `lib/app/router/app_router.dart`.
- [ ] **Step 9: Automated Tests**
  * Unit test the repository: verify cache hit, remote fetch, and fallback.
  * Unit test the controller: verify initial loading, success, and error mapping.
  * Widget test the screen: verify skeleton loader, data rendering, and retry CTA.
- [ ] **Step 10: Verification**
  * Run `flutter analyze` (must be 0 issues).
  * Run `flutter test` (all tests must pass).
