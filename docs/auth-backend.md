# auth-backend — Developer Guide

## 1. Overview

This slice delivers the authentication backend for BetterLife:

- **Register** (`POST /api/v1/auth/register`): creates a user, seeds 8 default categories, returns a JWT.
- **Login** (`POST /api/v1/auth/login`): validates credentials, returns a JWT.
- **Users** and **Categories** tables created via EF Core migration.
- JWT tokens: RS-256 signed (HS256), 30-day lifetime, configurable via env vars.
- Password hashing: BCrypt with work factor 12.

---

## 2. Prerequisites

| Requirement | Notes |
|---|---|
| .NET 8 SDK | `dotnet --version` should return `8.0.x` |
| SQL Server reachable on LAN | e.g. `192.168.1.35:1433` — the user manages this manually |
| Docker on LAN server (production only) | For running the compose stack |

---

## 3. Local Dev Workflow

SQL Server runs on the LAN server. The dev machine connects to it remotely via env vars.

### 3.1 Set environment variables (PowerShell)

```powershell
$env:ConnectionStrings__Default = "Server=192.168.1.35,1433;Database=BetterLife;User Id=sa;Password=YOUR_SA_PASSWORD;TrustServerCertificate=True;"
$env:Jwt__Secret = "your-dev-secret-at-least-32-chars-long-xxxxxxxxxx"
```

### 3.2 Run

```powershell
cd apps/api
dotnet run --project src/BetterLife.Api
```

On startup (Development environment only), EF Core migrations run automatically against the remote SQL Server. The application then starts on `http://localhost:5000` (or whichever port Kestrel assigns).

### 3.3 Swagger UI

Open `http://localhost:5000/swagger` in your browser.

---

## 4. Manual Smoke Test

### Step 1 — Verify SQL Server connectivity

```powershell
# Windows
Test-NetConnection 192.168.1.35 -Port 1433
```

```bash
# Linux / macOS
nc -zv 192.168.1.35 1433
```

### Step 2 — Set env vars and run

```powershell
$env:ConnectionStrings__Default = "Server=192.168.1.35,1433;Database=BetterLife;User Id=sa;Password=YOUR_PASSWORD;TrustServerCertificate=True;"
$env:Jwt__Secret = "your-dev-secret-min-32-chars-xxxxxxxxxxxxxxx"
dotnet run --project src/BetterLife.Api
```

### Step 3 — Verify migrations applied

Connect to SQL Server from any client and run:

```sql
SELECT * FROM __EFMigrationsHistory;
```

Expected: one row with `MigrationId` like `20260517043032_Initial`.

### Step 4 — Register a user

```bash
curl -X POST http://localhost:5000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"SecurePass123!","timeZone":"America/Argentina/Buenos_Aires"}'
```

Expected: `201 Created` with `{ "token": "...", "expiresAtUtc": "...", "user": { ... } }`.

### Step 5 — Login

```bash
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"SecurePass123!"}'
```

Expected: `200 OK` with token.

### Step 6 — Duplicate email (conflict)

```bash
curl -X POST http://localhost:5000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Another","email":"test@example.com","password":"SecurePass123!","timeZone":"America/Argentina/Buenos_Aires"}'
```

Expected: `409 Conflict` with `application/problem+json`.

### Step 7 — Wrong password

```bash
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"WrongPassword"}'
```

Expected: `401 Unauthorized` with `application/problem+json`.

### Step 8 — Validation error (bad email)

```bash
curl -X POST http://localhost:5000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"","email":"not-an-email","password":"short","timeZone":""}'
```

Expected: `400 Bad Request` with `application/problem+json` including field-level `errors` dictionary.

---

## 5. Production Deployment to LAN Server

1. Copy the repository (or clone) to the LAN server.
2. Navigate to `apps/api/`:
   ```bash
   cd apps/api
   cp .env.example .env
   ```
3. Edit `.env` with real values:
   - `CONNECTION_STRING`: use `Server=betterlife-sqlserver,1433;...` (compose service name, not IP).
   - `MSSQL_SA_PASSWORD`: strong password (8+ chars, upper, lower, digit, symbol).
   - `JWT_SECRET`: minimum 32 characters. Generate with `openssl rand -base64 48`.
4. Start the stack:
   ```bash
   docker compose up -d
   ```
5. On first startup, the API applies migrations automatically against the SQL Server container.
6. Verify: `curl http://<lan-server-ip>:8080/swagger` — Swagger UI should load.

> **Note**: On Production (`ASPNETCORE_ENVIRONMENT=Production`) migrations do NOT run automatically on startup. Apply them manually or via a migration job before deploying a new version with schema changes.

---

## 6. Generating New Migrations

When you add or change EF entities, generate a new migration from `apps/api/`:

```powershell
# Set dummy env vars (migration generation does not connect to DB)
$env:ConnectionStrings__Default = "Server=dummy;Database=BetterLife;User Id=sa;Password=Dummy_Pwd!1;TrustServerCertificate=True;"
$env:Jwt__Secret = "dummy-secret-for-migrations-only-min-32-chars-long-xxxxxxxxxxxxx"

dotnet ef migrations add <MigrationName> `
  --project src/BetterLife.Infrastructure `
  --startup-project src/BetterLife.Api
```

Commit the generated files under `src/BetterLife.Infrastructure/Migrations/`.

---

## 7. Troubleshooting

| Error | Cause | Fix |
|---|---|---|
| `Jwt:Secret must be at least 32 characters` | `Jwt__Secret` env var is missing or too short | Set `$env:Jwt__Secret` to a string ≥ 32 chars |
| `ConnectionStrings:Default missing` | `ConnectionStrings__Default` env var not set | Export the connection string before running |
| `A network-related or instance-specific error` | SQL Server unreachable | Check IP/port, firewall, SQL Server service status |
| Port 8080 already in use (Docker) | Another process or container on 8080 | Change the port mapping in `docker-compose.yml` |
| `The certificate chain was issued by an authority that is not trusted` | `TrustServerCertificate=False` or missing | Add `TrustServerCertificate=True;` to the connection string |
| Migrations not found at startup | `dotnet-ef` not installed | `dotnet tool install --global dotnet-ef --version 8.0.11` |
