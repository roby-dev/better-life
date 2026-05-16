# BetterLife - Technical Specification

## Product Direction

BetterLife is a personal habits and goals app focused on daily use. The user should be able to open the app, see today's habits, mark progress quickly, and review goals, history, and consistency without friction.

The product must prioritize:

1. Simplicity.
2. Daily use.
3. Clear Spanish UI.
4. Preservation of habit history.
5. Separation between habits, goals, completions, and categories.

## Target Experience

The app is mobile-first and initially focused on iPhone usage, while keeping Android support available through Flutter.

Visual direction:

- Warm and motivational.
- Clear, calm, and easy to scan.
- Spanish interface from the beginning.
- No overly complex gamification in the MVP.
- The user should feel encouraged, not judged.

Code conventions:

- Code, entities, classes, methods, database objects, and API contracts must use English.
- UI labels, messages, errors, and user-facing content must use Spanish.

Examples:

- Code: `Habit`, `Goal`, `HabitCompletion`, `ReminderTime`.
- UI: "Habitos de hoy", "Meta en progreso", "Marcar como completado".

## Locked Architectural Decisions

These decisions are CLOSED. Do not revisit during implementation unless an explicit new decision overrides them.

### Stack versions

- Backend: .NET 8 LTS. Can be bumped to 9/10 only if a concrete need appears.
- Mobile: Flutter stable (latest at scaffolding time).
- Database: SQL Server 2022 Developer edition, running in Docker.

### Identifiers

- All entities use `Guid` primary keys.
- IDs are generated on the CLIENT using UUID v7 (time-ordered, friendly for clustered indexes).
- The server respects client-provided IDs. All write endpoints behave as UPSERT by PK.
- EF Core must NOT auto-generate IDs (no `ValueGeneratedOnAdd` for entity IDs).
- Flutter uses the `uuid` package with v7 support to generate IDs before any local persistence or network send.

### Dates and timezones

- `HabitCompletion.CompletionDate` is a calendar date in the USER'S local timezone, persisted as SQL `DATE` and modeled as `DateOnly`.
- The client determines "today" in its local timezone and sends `YYYY-MM-DD`.
- The `Unique(UserId, HabitId, CompletionDate)` constraint enforces one-completion-per-user-per-day in the user's perceived day.
- The `User` entity stores `TimeZone` as IANA identifier (e.g. `"America/Argentina/Buenos_Aires"`) for future server-side reminder logic.
- All other timestamps (`CreatedAt`, `UpdatedAt`, `SyncedAt`, `CompletedAt`) are UTC.
- `Goal.TargetDate` is `DateOnly` in user-local terms.

### Authentication and JWT

- Password hashing: `BCrypt.Net-Next` with work factor 12. Hash stored in `User.PasswordHash`.
- JWT access token lifetime: 30 days. No refresh tokens in MVP.
- JWT claims: `sub` (UserId), `email`, `iat`, `exp`, `iss`, `aud`. No `Name` or other mutable fields.
- Signing secret, issuer, audience and lifetime read from environment variables.
- Flutter stores the token in `flutter_secure_storage`. Dio interceptor attaches it; on 401 the app clears it and redirects to login.

### ScheduledDays representation

- `Habit.ScheduledDays` is a `[Flags] enum WeekDays : int` persisted as `INT`.
- Bits: `Monday=1, Tuesday=2, Wednesday=4, Thursday=8, Friday=16, Saturday=32, Sunday=64`.
- Applies only when `FrequencyType == SpecificWeekDays`; `0` or `null` otherwise.
- Today query uses bitwise AND: `WHERE (ScheduledDays & @todayBit) != 0`.
- Flutter mirrors the same numeric representation in Drift for byte-compatible sync.

### Sync architecture

- Per-resource REST endpoints, all idempotent. Single `UpsertX` command per syncable entity (no separate Create/Update when the client owns the ID).
- Downlink endpoint: `GET /api/v1/sync?since={UtcTimestamp}` returns a `SyncChangesDto` with collections grouped by entity, filtered by server-side `UpdatedAt > since`.
- There is NO batch `POST /api/sync`. The Flutter sync queue fires individual requests with exponential backoff and retry.
- The server is the source of truth after each sync.
- For habit completions specifically, the latest client action for a given `(HabitId, CompletionDate)` wins.

### Soft delete

- All syncable entities (`Habit`, `Goal`, `Category`, `HabitCompletion`, `GoalHabit`) use `Status = Deleted` instead of physical DELETE so the downlink can propagate removals.
- `User` is the only entity with hard delete, only when the user requests account deletion (cascade clears all owned data).
- All read queries filter out `Deleted` rows by default.

### API versioning

- All endpoints are versioned in the URL from day 1: `/api/v1/...`.
- Use the `Asp.Versioning.Mvc` package (not the deprecated `Microsoft.AspNetCore.Mvc.Versioning`).
- Future v2 endpoints can coexist without breaking v1 clients.

### Categories seeding

- On user registration, the same transaction creates the user PLUS 8 default categories scoped to that user: Salud, Estudio, Trabajo, Finanzas, Familia, Espiritualidad, Productividad, Otro.
- `Category.Icon` is a short string identifier (e.g. `"heart"`, `"book"`, `"briefcase"`). The Flutter layer maps each identifier to a Material icon.
- Users can edit, soft-delete, and create their own categories afterward.

### Migrations

- EF Core code-first migrations are the only way to change schema.
- In Development, `Program.cs` runs `db.Database.MigrateAsync()` on startup automatically.
- In Production, migrations are applied manually or via deployment pipeline; the application does NOT auto-migrate in Production.

### Logging

- Serilog is the logging framework, configured via `appsettings.json` plus environment variables.
- Default sinks: Console and rolling file (daily rotation).
- Sensitive data (tokens, password hashes, request bodies on auth endpoints) must NEVER be logged.

### Mapping library

- **Mapster** (free, MIT) is the mapping library. NuGet: `Mapster`.
- AutoMapper is NOT used. Rationale: AutoMapper 14+ is commercial (paid license under Jimmy Bogard's commercial licensing, late 2024), and the last free version (13.0.1) carries an unpatched DoS advisory (GHSA-rvv3-g6hj-g44x). Staying on a frozen, vulnerable line was unacceptable; paying for a personal-use app is not justified.
- Mapster is roughly 3–4× faster than AutoMapper (compile-time source-gen capability), API is simpler, and the project has multiple maintainers — lower abandonment/relicense risk.
- Convention: call `source.Adapt<TargetDto>()`. Register custom mappings via `IRegister` classes scanned at startup. Do not embed business logic in mapping config.

### Library version pins (free/MIT only)

Several historically-default .NET libraries moved to commercial licensing in 2024. BetterLife pins to the last MIT-licensed versions to stay free:

- **MediatR `12.4.1`** — last MIT version. v13+ requires a commercial license. Pin explicit in the Application csproj.
- **Mapster** — current MIT version. No commercial fork planned.
- Do NOT run `dotnet add package MediatR` without `--version 12.4.1`; the default would bring v13+ and silently land us in a paid license.
- If MediatR is ever blocked by a real future need, consider Wolverine (free) or a hand-rolled dispatcher before paying.

### Transitive dependency hygiene

NuGet resolves transitive dependencies using "lowest applicable version", meaning a top-level package brings the minimum versions of its declared dependencies as they existed at publish time — even if newer patched versions exist. This regularly produces vulnerable transitives in .NET 8 unless actively managed.

Rules:

- After EVERY package add/upgrade, run `dotnet list <solution> package --vulnerable --include-transitive` and resolve any findings before committing.
- Prefer bumping the direct package to a newer patch release whose dependency graph already includes patched transitives (e.g., EF Core 8.0.11 fixed most of the chain that 8.0.8 left vulnerable).
- For remaining transitives that have no upstream patch yet, add an explicit `<PackageReference>` in the consuming project to override the resolved version. NuGet always honors direct refs over transitive resolution.
- Stay on the latest 8.0.x patch line for all Microsoft.* and EntityFrameworkCore.* packages. Do NOT cross into 9.x (we are pinned to .NET 8 LTS).

Current explicit transitive overrides:

- `BetterLife.Api` → `System.Text.Json` 8.0.5 (overrides 8.0.4 pulled by Swashbuckle/Serilog; patches GHSA-8g4q-xg66-9fp4).

When adding new override entries, document the override in this list with the advisory ID and what package was pulling the vulnerable version in.

Future consideration: migrate to Central Package Management (`Directory.Packages.props` at the solution root) so all pins live in one file. Deferred while the project is small.

### Tests deferred — testability not deferred

- No automated tests are written during MVP implementation.
- However, the code MUST be architected for future testing:
  - Handlers are pure functions of their inputs plus injected services.
  - All services are exposed through interfaces and registered via DI.
  - Specifically: `IPasswordHasher`, `IJwtTokenService`, `IClock` (no `DateTime.UtcNow` directly in handlers), `ICurrentUserAccessor` for resolving the authenticated user.
  - No static state, no service locator, no HTTP coupling in `Application` or `Domain` layers.
- When the test suite is later added, no refactor of business code should be required to enable it.

## Repository Structure

Use a monorepo.

```txt
/apps
  /mobile
    BetterLife Flutter app
  /api
    BetterLife ASP.NET Core API
/docs
  Product, architecture, decisions, and API notes
/docker
  Docker compose files and deployment helpers
spec.md
```

Keep the mobile app and backend independent enough to run separately, but version them together during MVP development.

## Technology Stack

### Mobile App

Use Flutter.

Required conventions:

- State management: Riverpod.
- Navigation: GoRouter.
- HTTP client: Dio.
- Local database/offline support: Drift with SQLite.
- Secure token storage: `flutter_secure_storage`.
- Date and formatting utilities: `intl`.

The Flutter app must be designed as an offline-capable client. It should not assume that the API is always reachable.

### Backend

Use ASP.NET Core Web API.

Required architecture:

- Clean Architecture.
- CQRS.
- MediatR.
- FluentValidation.
- Mapster for DTO/entity mapping (replaces AutoMapper — see Locked Decisions → Mapping library).
- Entity Framework Core.
- SQL Server.

Backend layers:

```txt
/apps/api
  /src
    /BetterLife.Api
    /BetterLife.Application
    /BetterLife.Domain
    /BetterLife.Infrastructure
  /tests
    /BetterLife.UnitTests
    /BetterLife.IntegrationTests
```

Layer responsibilities:

- `Domain`: entities, value objects, enums, domain rules.
- `Application`: CQRS commands/queries, handlers, DTOs, interfaces, validation.
- `Infrastructure`: EF Core, SQL Server persistence, external services, JWT implementation, notification providers.
- `Api`: controllers/endpoints, middleware, dependency injection, auth configuration, Swagger/OpenAPI.

### Database

Use SQL Server as the main database.

Use code-first EF Core migrations.

Database changes must be represented through migrations. Avoid manual schema drift.

### Deployment

Target deployment:

- Ubuntu server.
- Docker installed.
- API and SQL Server running through Docker Compose.
- Configuration through `.env`.
- Cloudflare exposure is planned later and should not be required for local MVP development.

Initial Docker scope:

```txt
docker-compose.yml
- betterlife-api
- betterlife-sqlserver
```

The app must support local development without production infrastructure.

## Backend Architecture Rules

### CQRS

Commands must represent state changes.

Examples:

- `CreateHabitCommand`
- `UpdateHabitCommand`
- `PauseHabitCommand`
- `CompleteHabitCommand`
- `CreateGoalCommand`
- `AssociateHabitToGoalCommand`

Queries must read data without side effects.

Examples:

- `GetTodayHabitsQuery`
- `GetHabitHistoryQuery`
- `GetGoalProgressQuery`
- `GetUserCategoriesQuery`

Each command/query should have:

- Request object.
- Handler.
- DTO or result type.
- FluentValidation validator when input validation is needed.

### Validation

Use FluentValidation for application-level input validation.

Validation examples:

- Habit name is required.
- Habit frequency is required.
- Goal name is required.
- Email format must be valid.
- Password must meet minimum security rules.

Domain invariants should remain in the domain layer when they protect business correctness.

### Mapping

Use **Mapster** for DTO/entity mapping. Mapster is free (MIT), actively maintained, generates code at compile time (faster than reflection-based mappers), and has no commercial-licensing risk.

Conventions:

- Mapping is performed via the `Adapt<T>()` extension method (e.g., `habit.Adapt<HabitDto>()`).
- Custom mappings live in static configuration classes that implement `IRegister`, scanned at startup via `TypeAdapterConfig.GlobalSettings.Scan(assembly)`.
- Do NOT hide business rules inside mapping config — mapping is for shape conversion only.
- If a mapping needs business logic, put that logic in a domain method or application service and call it from the handler, not from Mapster config.

AutoMapper is NOT used (see Locked Decisions → Mapping library for the rationale).

### Authentication

Use custom email/password authentication with password hashing and JWT. ASP.NET Identity is NOT used in MVP.

See **Locked Architectural Decisions → Authentication and JWT** for the concrete algorithm, lifetimes, and claims.

Authentication requirements:

- Register with name, email, password, and IANA timezone.
- Login with email and password.
- Store BCrypt password hashes only; never plain text.
- Issue a 30-day JWT access token (no refresh in MVP).
- Every API endpoint that exposes personal data requires authentication.
- The authenticated `UserId` comes from the JWT `sub` claim. Endpoints MUST NOT accept `UserId` from the client for normal user operations.
- Registration creates the user PLUS the 8 default categories in the same transaction.

## Core Domain Model

All entity `Id` fields are `Guid` generated client-side as UUID v7 (see Locked Decisions → Identifiers). All `CreatedAt` / `UpdatedAt` / `SyncedAt` / `CompletedAt` are UTC. All syncable entities use soft delete (`Status = Deleted`).

### User

Represents the person using BetterLife.

Fields:

- `Id` (Guid v7)
- `Name`
- `Email` (unique)
- `PasswordHash` (BCrypt, work factor 12)
- `TimeZone` (IANA identifier, e.g. `"America/Argentina/Buenos_Aires"`)
- `Status` (`Active` | `Deleted`)
- `CreatedAt` (UTC)
- `UpdatedAt` (UTC)

Note: `User` is the only entity that supports hard delete (only when the user requests account deletion; cascade clears all owned data).

### Habit

Represents a repeated action the user wants to track.

Fields:

- `Id` (Guid v7)
- `UserId` (Guid)
- `Name`
- `Description` (optional)
- `CategoryId` (Guid)
- `FrequencyType` (`Daily` | `SpecificWeekDays` | `Weekly`)
- `ScheduledDays` (`[Flags] WeekDays : int`, only meaningful when `FrequencyType == SpecificWeekDays`)
- `ReminderTime` (`TimeOnly?`, in user's local timezone)
- `Status` (`Active` | `Paused` | `Deleted`)
- `CreatedAt` (UTC)
- `UpdatedAt` (UTC)

Rules:

- A habit name is required.
- A frequency is required.
- New habits start `Active`.
- `Paused` habits do not appear in "today's habits" but keep their full history.
- Editing a habit must not delete previous completions.
- Soft delete only (`Status = Deleted`). History survives deletion for analytics/sync.

### Goal

Represents a personal objective.

Fields:

- `Id` (Guid v7)
- `UserId` (Guid)
- `Name`
- `Description` (optional)
- `CategoryId` (Guid, optional)
- `TargetDate` (`DateOnly?`, user-local)
- `Status` (`InProgress` | `Completed` | `Paused` | `Cancelled` | `Deleted`)
- `ManualProgress` (`int?`, 0-100, used when the goal has no associated habits)
- `CreatedAt` (UTC)
- `UpdatedAt` (UTC)
- `CompletedAt` (UTC, set when `Status` transitions to `Completed`)

Rules:

- A goal name is required.
- New goals start with `Status = InProgress`.
- A goal can exist without associated habits.
- Goals without associated habits may use `ManualProgress`.
- Soft delete only.

### HabitCompletion

Represents a habit completed on a specific date.

Fields:

- `Id` (Guid v7)
- `UserId` (Guid)
- `HabitId` (Guid)
- `CompletionDate` (`DateOnly`, user-local — see Locked Decisions → Dates and timezones)
- `Status` (`Completed` | `NotCompleted` | `Corrected` | `Deleted`)
- `Note` (optional)
- `CreatedAt` (UTC)
- `UpdatedAt` (UTC)
- `SyncedAt` (UTC, nullable — set when server confirms persistence)

Rules:

- A habit can only have one active completion per user per day.
- The user can correct an accidental completion (the row is updated, never duplicated).
- History must be preserved even if the habit is paused or soft-deleted.
- Conflict rule on sync: for a given `(HabitId, CompletionDate)` the latest client action (highest `UpdatedAt`) wins.

Database constraint:

```txt
Unique(UserId, HabitId, CompletionDate)
```

### Category

Categories are customizable per user.

Fields:

- `Id` (Guid v7)
- `UserId` (Guid)
- `Name`
- `Color` (hex string, e.g. `"#E26D5A"`)
- `Icon` (short string identifier, e.g. `"heart"`, `"book"` — Flutter maps to Material icons)
- `Status` (`Active` | `Deleted`)
- `CreatedAt` (UTC)
- `UpdatedAt` (UTC)

Rules:

- Categories belong to a user (not global).
- On registration the system seeds the 8 default categories in the same transaction as user creation.
- Users can create, edit, and soft-delete their categories.
- Deleting a category does NOT cascade to habits/goals; those keep `CategoryId` as a tombstoned reference until the user reassigns them.

Default category examples:

- Salud
- Estudio
- Trabajo
- Finanzas
- Familia
- Espiritualidad
- Productividad
- Otro

### GoalHabit

Represents the many-to-many association between goals and habits.

Fields:

- `Id` (Guid v7) — own PK so the sync queue can address the association directly
- `GoalId` (Guid)
- `HabitId` (Guid)
- `Status` (`Active` | `Deleted`)
- `CreatedAt` (UTC)
- `UpdatedAt` (UTC)

Rules:

- A goal can have many habits; a habit can contribute to many goals.
- Removing an association is a soft delete; the habit and its history remain intact.
- Unique constraint: `Unique(GoalId, HabitId)` filtered on `Status != Deleted`.

## Enums

Use English enum names in code.

Suggested enums:

```txt
HabitStatus
- Active
- Paused
- Deleted

GoalStatus
- InProgress
- Completed
- Paused
- Cancelled

CompletionStatus
- Completed
- NotCompleted
- Corrected

FrequencyType
- Daily
- SpecificWeekDays
- Weekly
```

Map enum values to Spanish labels only in the UI layer.

## Offline Strategy

BetterLife must support offline usage in the MVP.

MVP offline scope:

- The user can view cached habits, goals, categories, history, and today's plan.
- The user can mark and unmark habits while offline.
- Offline changes are stored locally.
- Changes synchronize when connectivity returns.

Out of scope for first offline slice:

- Full offline conflict resolution for every entity.
- Complex multi-device merge flows.
- Offline-first creation and editing of every object, unless added deliberately later.

Mobile local persistence:

- Use Drift with SQLite.
- Store enough data to render today's habits and recent history.
- Store pending local operations in a sync queue.

Suggested local sync queue fields:

- `Id`
- `EntityType`
- `EntityId`
- `OperationType`
- `PayloadJson`
- `CreatedAt`
- `LastAttemptAt`
- `AttemptCount`
- `Status`

Sync principles:

- Prefer idempotent API operations where possible.
- Habit completion sync must respect the one-completion-per-day rule.
- Server remains the source of truth after synchronization.
- The app should clearly handle "pending sync" states without alarming the user.

Conflict rule for MVP:

- For habit completions, the latest user action for a given `HabitId` and date wins.
- For broader entity edits, defer conflict resolution until offline editing is explicitly implemented.

## Notifications And Reminders

Push notifications need more evaluation before a final implementation decision.

Current direction:

- The app should be architected to support push notifications later.
- Do not hard-code the reminder system in a way that blocks push notifications.
- Keep reminder-related fields on habits, such as `ReminderTime`.
- Keep backend concepts ready for device registration.

Evaluation needed:

- Firebase Cloud Messaging support for Flutter iOS and Android.
- Apple Push Notification requirements.
- Whether reminders should be local-only, server-triggered, or hybrid.
- How reminders behave when the user is offline.
- How many devices per user must be supported.
- Whether a home-server deployment can reliably trigger scheduled notifications.

Likely future architecture:

```txt
Flutter App
  Registers device token
  Receives push notification

.NET API
  Stores device tokens
  Stores reminder preferences
  Determines eligible reminders

Background Worker
  Runs scheduled reminder checks
  Sends push notifications through provider
```

Potential MVP reminder fallback:

- Use local notifications on the device for habit reminder times.
- Later add push notifications for cross-device or server-driven reminders.

Do not implement push notifications until the evaluation is completed and documented.

## API Guidelines

Use REST endpoints for the MVP. All endpoints are versioned under `/api/v1/...` from day 1 using `Asp.Versioning.Mvc`.

Swagger/OpenAPI must be enabled in Development.

Endpoint groups:

```txt
/api/v1/auth           POST /register, POST /login
/api/v1/habits         GET, POST (upsert), GET /{id}, PUT /{id}, DELETE /{id} (soft)
/api/v1/habit-completions  POST (upsert), DELETE /{id} (soft)
/api/v1/goals          GET, POST (upsert), GET /{id}, PUT /{id}, DELETE /{id} (soft)
/api/v1/goal-habits    POST (upsert), DELETE /{id} (soft)
/api/v1/categories     GET, POST (upsert), GET /{id}, PUT /{id}, DELETE /{id} (soft)
/api/v1/today          GET (today's scheduled habits + their completion state)
/api/v1/history        GET (range queries over completions)
/api/v1/progress       GET (streaks, goal progress summaries)
/api/v1/sync           GET ?since={UtcTimestamp}  (downlink only — never POST)
```

Conventions:

- All write endpoints behave as UPSERT keyed by client-provided `Id` (Guid v7). Re-sending the same payload is idempotent.
- All personal-data endpoints derive `UserId` from the JWT `sub` claim. NEVER trust a `UserId` in the request body or query string.
- Use request/response DTOs. Do NOT expose EF entities directly.
- Validation via FluentValidation runs as a MediatR pipeline behavior before the handler.
- Errors follow RFC 7807 (`application/problem+json`).
- Soft-delete endpoints return 204 on success.

Sync downlink shape (`GET /api/v1/sync?since={utc}`):

```jsonc
{
  "serverTime": "2026-05-16T14:00:00Z",
  "categories":        [ /* Category DTOs changed since `since` */ ],
  "habits":            [ /* Habit DTOs */ ],
  "goals":             [ /* Goal DTOs */ ],
  "goalHabits":        [ /* GoalHabit DTOs */ ],
  "habitCompletions":  [ /* HabitCompletion DTOs */ ]
}
```

The client persists `serverTime` as the next `since` cursor on success.

## Mobile App Structure

Suggested Flutter structure:

```txt
/apps/mobile/lib
  /app
    router.dart
    theme.dart
  /core
    network
    storage
    sync
    errors
  /features
    /auth
    /today
    /habits
    /goals
    /history
    /progress
    /categories
  /shared
    widgets
    models
    utils
```

Feature folders should contain their own presentation, application/state, data, and domain-like models as needed.

Use Riverpod providers consistently. Avoid mixing multiple state management styles.

Use GoRouter for app navigation and protected auth routes.

Use Dio interceptors for:

- JWT attachment.
- 401 handling.
- API errors.
- Optional request logging in development.

## UI Language

All user-facing text must be Spanish.

Examples:

- "Iniciar sesion"
- "Crear cuenta"
- "Habitos de hoy"
- "Completado"
- "Pendiente"
- "Meta en progreso"
- "Sin conexion. Guardaremos tus cambios para sincronizarlos luego."

Keep Spanish copy simple and friendly.

## UI Screens (Mockup Specification)

This section is the source of truth for mockups. Every screen below is in scope for MVP. All user-facing strings are Spanish (Rioplatense neutral, friendly, no shouting). Code identifiers stay English.

### Visual Direction

- **Mood**: warm, motivational, calm. The user should feel encouraged, never judged.
- **Palette** (suggested, design may refine):
  - Background: cálido off-white `#FAF7F2` (light) / cálido near-black `#1C1A18` (dark).
  - Surface: `#FFFFFF` light / `#26231F` dark.
  - Primary accent (terracota cálido): `#D4694A`.
  - Secondary accent (verde salvia): `#7A9B76`.
  - Success: `#5B8A5A`. Warning: `#D8A24A`. Error: `#C25450`.
  - Text primary: `#2A2622` light / `#F2EFEA` dark.
  - Text muted: `#7A716A`.
- **Typography**: una sola familia humanista (sugerido Inter o Manrope). Pesos 400/500/600/700. Tamaños base 14/16/18/22/28.
- **Forma**: corners redondeados 12–16 px en cards y botones. Shadows suaves, no neumorfismo.
- **Iconografía**: Material Symbols (rounded). Identificadores cortos para iconos en datos (`heart`, `book`, `briefcase`, `wallet`, `users`, `sparkle`, `bolt`, `tag`).
- **Densidad**: espaciado generoso (mínimo 16 px gutter, 24 px entre secciones). Touch targets 48 px mínimos.
- **Microinteracciones**: tap en checkbox de hábito → escala 0.95→1.05→1.0 con haptic suave + fade del color de fondo (gris → verde sage). Sin confetti ni gamificación ruidosa.

### Global Patterns

- **Bottom navigation** (4 tabs, presente en pantallas principales): `Hoy`, `Hábitos`, `Metas`, `Más`.
- La pestaña `Más` abre una pantalla menú con: `Historial`, `Progreso`, `Categorías`, `Perfil`.
- **FAB** (botón de acción flotante) en `Hábitos` y `Metas` → "Nuevo hábito" / "Nueva meta".
- **AppBar** muestra título de sección. En detail screens lleva back arrow + acciones contextuales (editar, pausar, eliminar).
- **Estado offline**: banner superior delgado, color warning suave, copy: `"Sin conexión. Tus cambios se sincronizarán solos."`. Desaparece al recuperar conexión.
- **Estado "sincronizando pendientes"**: chip pequeño en la esquina superior derecha con ícono giratorio y contador (`"3 pendientes"`). No es bloqueante.
- **Empty states**: ilustración minimalista + copy cálido + CTA primario. Nunca dejar la pantalla vacía.
- **Loading**: skeleton shimmer (no spinner pleno) salvo pantallas de transición (splash, post-login).
- **Errores**: SnackBar con texto humano. Botón `"Reintentar"` cuando aplique.

### Screen Inventory

#### 1. Splash

- **Propósito**: branding, mientras se carga config + token.
- **Layout**: logo centrado, nombre `"BetterLife"` debajo, indicador sutil de carga al pie.
- **Estados**: token válido → `Hoy`. Sin token → `Iniciar sesión`.
- **Tiempo máximo**: 1.5 s antes de avanzar.

#### 2. Iniciar sesión

- **Propósito**: autenticar con email + contraseña.
- **Layout**: scroll vertical centrado. Header con saludo `"Bienvenido de vuelta"`. Subtítulo `"Seguimos donde lo dejaste."`.
- **Campos**:
  - Email (`"Email"`, validación formato).
  - Contraseña (`"Contraseña"`, toggle mostrar/ocultar).
- **Acciones**:
  - Botón primario `"Iniciar sesión"` (full width).
  - Link secundario `"Crear cuenta"`.
- **Estados**: loading en el botón. Error genérico: `"Email o contraseña incorrectos."`. Sin "olvidé mi contraseña" en MVP.

#### 3. Crear cuenta

- **Propósito**: registro nuevo.
- **Layout**: idem login, con cuatro campos.
- **Campos**:
  - Nombre (`"Tu nombre"`).
  - Email (`"Email"`, formato).
  - Contraseña (`"Contraseña"`, mínimo 8, fortaleza visible).
  - Zona horaria (`"Zona horaria"`, dropdown con búsqueda — default = device timezone).
- **Acciones**:
  - Botón primario `"Crear cuenta"`.
  - Link `"Ya tengo cuenta"`.
- **Post-registro**: navegación directa a `Hoy`, con onboarding inline mínimo (un toast: `"Te dejamos algunas categorías para empezar."`).

#### 4. Hoy (home — tab default)

- **Propósito**: vista diaria de hábitos programados para HOY. Es la pantalla más usada.
- **Layout**:
  - Header sticky con fecha en grande: `"Jueves 16 de mayo"` + saludo dinámico (`"Buenos días, Roby."` según hora).
  - Resumen del día: pill con `"3 de 5 completados"` y barra de progreso fina.
  - Lista de hábitos del día, agrupados por momento sugerido si aplica (`Mañana`, `Tarde`, `Noche`), si no, lista simple.
  - Cada ítem: checkbox circular grande a la izquierda, nombre del hábito, chip de categoría con su color/ícono, `ReminderTime` si tiene, indicador discreto de racha (`"🔥 7"` — único uso de emoji aceptado en MVP, opcional).
  - Tap en el checkbox → marca/desmarca completion (optimista, se sincroniza solo).
  - Tap en el ítem (no en el checkbox) → `Detalle de hábito`.
- **Empty state**: ilustración + `"Sin hábitos programados para hoy."` + CTA `"Crear hábito"` (lleva a Crear hábito).
- **Estado offline**: la lista funciona igual; cambios quedan en cola.
- **Bottom nav**: `Hoy` activo.

#### 5. Hábitos (tab)

- **Propósito**: gestionar todos los hábitos (activos + pausados).
- **Layout**:
  - Tabs internos: `Activos` (default), `Pausados`.
  - Lista de hábitos: nombre, categoría (chip), frecuencia legible (`"Todos los días"`, `"Lun, Mié, Vie"`, `"Una vez por semana"`), `ReminderTime` si tiene.
  - Tap → `Detalle de hábito`.
  - Long-press → menú rápido (`Editar`, `Pausar/Reanudar`, `Eliminar`).
- **FAB**: `"Nuevo hábito"` → `Crear/Editar hábito`.
- **Empty state**: `"Todavía no creaste ningún hábito."` + CTA primario.

#### 6. Crear / Editar hábito

- **Propósito**: formulario único para crear o editar.
- **Layout**:
  - AppBar: `"Nuevo hábito"` o `"Editar hábito"`. Acción `"Guardar"` arriba a la derecha.
  - Campos:
    - Nombre (`"Nombre del hábito"`, requerido).
    - Descripción (`"Descripción (opcional)"`, textarea corta).
    - Categoría (selector con grid de chips coloridos; opción `"Crear categoría"` al final).
    - Frecuencia (radio group):
      - `Todos los días`
      - `Días específicos` → al elegir, muestra 7 toggles `L M M J V S D`.
      - `Una vez por semana`
    - Recordatorio (`"Recordarme a las..."`, time picker, opcional; toggle on/off).
  - Botón primario al pie (sólo en mobile portrait): `"Guardar hábito"`.
- **Estados**:
  - Validación inline (nombre vacío, días vacíos si eligió "Días específicos").
  - Loading en submit.

#### 7. Detalle de hábito

- **Propósito**: ver historia y meta-info de un hábito.
- **Layout**:
  - Header con nombre + chip de categoría.
  - Stats row: racha actual, mejor racha, total completados, % últimos 30 días.
  - Mini-calendario mensual: días marcados con punto del color de la categoría. Navegable mes a mes.
  - Sección `"Metas asociadas"`: lista breve de goals que incluyen este hábito (chip clickable → detalle de meta).
  - Botones inferiores: `Editar`, `Pausar / Reanudar`, `Eliminar` (destructivo, requiere confirmación: `"¿Eliminar este hábito? Tus completions se conservan."`).

#### 8. Metas (tab)

- **Propósito**: gestionar metas personales.
- **Layout**:
  - Tabs internos: `En curso`, `Completadas`, `Pausadas`.
  - Cada card: nombre, categoría chip, barra de progreso (calculada de habits asociados o `ManualProgress`), `TargetDate` legible (`"Para el 31 de jul"`), número de hábitos asociados.
  - Tap → `Detalle de meta`.
- **FAB**: `"Nueva meta"`.
- **Empty state**: `"Aún no definiste ninguna meta. Una meta clara guía tus hábitos."` + CTA.

#### 9. Crear / Editar meta

- **Layout**:
  - Campos:
    - Nombre (requerido).
    - Descripción (opcional).
    - Categoría (selector chips).
    - Fecha objetivo (date picker, opcional).
    - Modo de progreso (radio):
      - `Por hábitos asociados` (default; el progreso se calcula automático).
      - `Manual` → muestra slider 0–100%.
    - (Opcional) sección `"Asociar hábitos ahora"` con multi-select de hábitos activos. También se puede hacer después desde el detalle.
  - Submit: `"Guardar meta"`.

#### 10. Detalle de meta

- **Layout**:
  - Header con nombre + categoría + estado (`En curso`, `Completada`...).
  - Progreso circular grande con `%`.
  - `TargetDate` con días restantes (`"En 47 días"` o `"Vencida hace 3 días"`).
  - Sección `"Hábitos asociados"`: lista con cada hábito y su % personal de aporte. Botones `+ Asociar hábito` y swipe-to-remove en cada uno (confirmación: la asociación se borra, el hábito y su historia siguen).
  - Botones: `Editar`, `Marcar como completada`, `Pausar`, `Cancelar`, `Eliminar`.

#### 11. Historial

- **Propósito**: ver completions pasadas a lo largo del tiempo.
- **Layout**:
  - Selector de rango arriba (`Semana`, `Mes`, `3 meses`, `Año`).
  - Heatmap estilo GitHub (filas = hábitos, columnas = días) o calendario mensual con dots — diseño elige el tratamiento más cálido.
  - Filtros: por categoría (multi-chip), por hábito específico.
  - Tap en un día → bottom sheet con la lista de hábitos completados ese día.

#### 12. Progreso

- **Propósito**: resumen agregado para motivar.
- **Layout**:
  - Cards apilables:
    - `Racha global`: días consecutivos con al menos un hábito completado.
    - `Mejor racha histórica`.
    - `Top 3 hábitos del mes` (más consistentes).
    - `Metas en curso` (resumen con barras).
    - `Distribución por categoría` (donut o stacked bar).
  - Sin métricas negativas. Foco en celebrar lo que SÍ se hizo.

#### 13. Categorías

- **Propósito**: ver, crear, editar y borrar categorías personales.
- **Layout**:
  - Grid 2 columnas. Cada card: ícono + nombre + color de fondo suave.
  - Tap → bottom sheet de edición (nombre, color picker — paleta cálida fija de ~12 colores, ícono picker).
  - FAB: `"Nueva categoría"`.
  - Long-press → eliminar (confirmación: `"Los hábitos y metas con esta categoría quedan sin asignar."`).

#### 14. Perfil

- **Propósito**: info personal, settings, logout.
- **Layout**:
  - Cabecera con nombre + email.
  - Secciones:
    - `Cuenta` → `Nombre`, `Email` (no editable en MVP), `Zona horaria` (editable).
    - `Datos` → `Sincronizar ahora` (botón manual), `Última sincronización: hace 3 min`.
    - `Acerca de` → versión de la app, enlaces dummy.
    - `Cerrar sesión` (botón destructivo al pie, confirmación).

### Navigation Map

```
Splash
 ├─ (token válido)  → Hoy
 └─ (sin token)     → Iniciar sesión
                       ├─ → Crear cuenta → Hoy
                       └─ → Hoy

Bottom nav (post-auth):
 Hoy ──────────────────────── Detalle de hábito
 Hábitos ──── Crear/Editar ── Detalle de hábito
 Metas ────── Crear/Editar ── Detalle de meta ── Asociar hábitos
 Más
  ├─ Historial
  ├─ Progreso
  ├─ Categorías ── Crear/Editar categoría
  └─ Perfil ── Cerrar sesión → Iniciar sesión
```

### Copy Reference (palette of approved Spanish phrasing)

- "Hábitos de hoy", "Meta en progreso", "Marcar como completado", "Sin completar"
- "Crear cuenta", "Iniciar sesión", "Cerrar sesión"
- "Sin conexión. Tus cambios se sincronizarán solos."
- "Sincronizado", "{N} cambios pendientes"
- "Racha actual", "Mejor racha", "Completados esta semana"
- "¿Eliminar este hábito? Tus completions se conservan."
- "Todavía no creaste ningún hábito.", "Aún no definiste ninguna meta."
- "Buenos días", "Buenas tardes", "Buenas noches" (según hora local).
- Tono: corto, cálido, en segunda persona singular (voseo neutral). Nunca culpabilizar. Nunca usar "¡!" para presionar.

## MVP Implementation Order

Recommended order (no tests during MVP, but every step keeps code testable):

1. Monorepo setup.
2. Docker Compose with API and SQL Server.
3. .NET 8 solution with Clean Architecture projects + Serilog + Asp.Versioning + DI registrations for `IClock`, `IPasswordHasher`, `IJwtTokenService`, `ICurrentUserAccessor`.
4. EF Core base configuration, soft-delete query filters, first migration (Users, Categories, Habits, Goals, GoalHabits, HabitCompletions).
5. Auth: register (with seed of 8 default categories in same transaction), login, JWT issuance.
6. Flutter app shell with theme, GoRouter, auth screens, Dio + interceptors, `flutter_secure_storage`.
7. Categories CRUD (API + Flutter).
8. Habits CRUD (API + Flutter, including bitmask handling).
9. `GetTodayHabitsQuery` and the `Hoy` screen.
10. Mark/unmark habit completion (upsert `HabitCompletion`).
11. Drift local cache for today's plan and recent completions.
12. Offline sync queue + downlink `GET /api/v1/sync?since=...` integration.
13. Goals CRUD.
14. Goal-habit associations.
15. Progress summary (server-side aggregation + `Progreso` screen).
16. History view (`Historial` screen).
17. Reminder evaluation document (decide local-only vs. server-driven before any reminder code is written).

## Testing Expectations

**Automated tests are DEFERRED for the MVP.** No unit, integration, or widget tests are written during the initial implementation.

However, the codebase MUST remain testable from day 1 (see Locked Decisions → Tests deferred — testability not deferred):

- Handlers are pure functions of inputs plus injected services. No `DateTime.UtcNow` directly inside handlers — use `IClock`.
- All cross-cutting services are interfaces, registered via DI: `IPasswordHasher`, `IJwtTokenService`, `IClock`, `ICurrentUserAccessor`.
- `Domain` and `Application` layers have NO dependencies on HTTP, EF Core types in signatures, or static state.
- Flutter state providers expose business logic in plain Dart functions/classes that can be unit-tested without Flutter widgets.

When the test suite is later added, these areas must be the FIRST covered (highest business risk):

- Authentication (register + login + token issuance).
- Completion once-per-day rule (unique constraint + upsert behavior).
- Today's habit calculation (bitmask + timezone correctness).
- Offline completion sync (queue dispatch, retry, idempotency under retries).
- User data isolation (no leak across `UserId`).

Adding tests later MUST NOT require refactoring business code — only new test projects/files.

## Development Conventions

General:

- Keep MVP scope strict.
- Avoid adding social, rankings, payments, AI recommendations, advanced gamification, or marketplace features.
- Preserve history when editing or pausing habits.
- Prefer clear code over clever abstractions.

Backend:

- Use nullable reference types.
- Use async APIs for database and IO operations.
- Keep controllers thin.
- Keep business rules in Application/Domain, not controllers.
- Use `CancellationToken` in handlers and persistence calls.
- Use environment variables for secrets and connection strings.

Flutter:

- Prefer small feature-focused widgets.
- Keep API models separate from local database models when needed.
- Show offline/sync states gently.
- Avoid blocking daily usage behind non-essential screens.

## Open Decisions

The following decisions are intentionally not final yet:

- Push notification provider and architecture (FCM vs APNs vs hybrid; local notifications as MVP fallback).
- Whether local notifications are enough for MVP reminders.
- When and how to introduce refresh tokens (additive over current 30-day access token; not breaking).
- Production reverse proxy and Cloudflare Tunnel setup.
- Multi-device conflict resolution for entities other than `HabitCompletion`.
- Whether to add a "weekly target" semantics for `FrequencyType == Weekly` (any day vs. user-chosen day vs. count-based).
- When to bring automated tests in (tests deferred for MVP, not abandoned — see Testing Expectations).

Document each decision before implementation if it affects architecture.
