# log_strategy_copilot_instructions.md

You are assisting on a Flutter (Dart) project that needs a **maintenance-friendly logging strategy**, similar to server log digging (hourly logs, correlation IDs), but optimized for mobile development.

Follow the rules below strictly.

---

## 0) Goals

1. **Developer-stage PC log digging**
   - Logs must be visible on the developer machine via:
     - `flutter logs` (preferred) OR
     - `adb logcat` filtering by package name
   - Logs should be easy to grep/filter and optionally pipe to files on the PC.

2. **Structured, consistent logs**
   - No ad-hoc `print()` scattered across the codebase.
   - Prefer structured logs (level + tag + message + metadata + optional error/stack).

3. **Correlation IDs**
   - Every “user action” or request chain should have a `corrId` so we can follow end-to-end flows.

4. **Safe by default**
   - Never log secrets or PII (tokens, passwords, full auth headers, full personal data, full payment data).

5. **Extensible**
   - Later, we can fan-out logs to:
     - remote crash/error reporting (Crashlytics/Sentry)
     - optional local file export (JSONL + zip) for support
   - Do not over-engineer during early development.

---

## 1) Logging Architecture

### 1.1 Single entry point: `AppLogger`
- Create one central interface/class `AppLogger` used everywhere.
- No direct usage of `print()` or `developer.log()` in feature code.
- The logger must support:
  - `debug/info/warn/error`
  - `tag` (e.g., AUTH, NETWORK, DB, UI, FLOW)
  - `corrId` (optional, but included when available)
  - `metadata` (Map<String, Object?>)
  - `error` + `stackTrace`

### 1.2 Where to place logging code
Recommended structure (simple, DDD-friendly):

- `lib/core/logging/`
  - `app_logger.dart` (interface + implementation)
  - `log_event.dart` (optional small DTO/entity)
  - `log_sanitizer.dart` (redaction helpers)
  - `correlation_id.dart` (corrId generation + scope)
  - `log_tags.dart` (enum/const tags)

Features should depend only on `AppLogger` (or a small `LoggerPort`).

### 1.3 Dependency injection / construction
- Prefer constructor injection when possible.
- If using a service locator (e.g., `get_it`), register `AppLogger` once and retrieve it only in composition root.
- Do not create new logger instances per feature; keep it singleton.

---

## 2) Log Format (must be consistent)

All log lines must follow a parse-friendly format:

<TS_ISO8601> <LEVEL> <TAG> <corrIdOrDash> <message> <json_metadata_if_any>


Example:

2026-02-04T19:12:33.120Z INFO AUTH 8f3a2a "Google sign-in started" {"provider":"google"}


### Required fields
- Timestamp: ISO-8601 UTC (`DateTime.now().toUtc().toIso8601String()`)
- Level: DEBUG/INFO/WARN/ERROR
- Tag: short category
- corrId: string or `-`
- message: short, human-readable
- metadata: JSON object if present (single-line)

### Metadata rules
- Keep metadata shallow (no huge nested payloads).
- Never dump full HTTP bodies for production.
- For development, allow limited samples only when explicitly requested and sanitized.

---

## 3) Correlation ID Strategy

### 3.1 When to generate a corrId
Generate a new `corrId` at these boundaries:
- A user action starts (button press, page action, submit form)
- A use-case / flow starts (e.g., login flow, create order, payment start)
- A network request chain begins

### 3.2 How to propagate corrId
- Pass corrId as a parameter through calls:
  - UI -> controller/service -> repository -> network
- For HTTP calls, include corrId in logs and optionally in a request header in debug builds:
  - `X-Correlation-Id: <corrId>` (debug only)

### 3.3 Logging a flow
For important flows, include:
- `FLOW_START`
- step logs with same corrId
- `FLOW_END` with outcome (success/failure) + duration

---

## 4) Development Stage: PC Log Digging (must support)

### 4.1 How developers view logs
The project must work well with:

- `flutter logs`
- `adb logcat`

So logs must be printed to console in a single line per event.

### 4.2 Recommended PC commands (document in README)
Windows PowerShell examples:

```powershell
# Live logs
flutter logs

# Filter by package (if needed)
adb logcat | findstr com.menumia.partner

# Save logs to a file
flutter logs | Tee-Object -FilePath .\logs\app-dev.log
Do not implement file rotation inside the app for development-only needs.
Prefer piping logs to files on the PC.

5) Production / Later Stage (design now, implement later)
5.1 Remote error reporting (recommended)
Add a sink later:

Crashlytics or Sentry

Only send WARN/ERROR by default

Include corrId in reported breadcrumbs

5.2 Optional: local file logging + export (only if needed)
If required for support:

Use JSONL (1 JSON per line)

Rotate by hour or size (e.g., 5–10MB)

Retain last N files (e.g., 24–48 hours)

Provide “Export Logs” button that zips selected files

Always sanitize and avoid secrets

6) Security & Redaction Rules (must follow)
Never log:

access tokens, refresh tokens, OAuth codes

Authorization headers

passwords, PINs

full emails/phone numbers (mask)

full payment details

Always sanitize:

headers: remove Authorization, Cookie

user identifiers: hash or partially mask

payloads: log only small safe fields

Implement helpers in log_sanitizer.dart:

maskEmail("a@b.com") -> "a***@b.com"

maskPhone("90555...") -> "9055*****"

redactHeaders(map) -> remove sensitive keys

7) Performance Rules
Logging must be non-blocking for UI:

build strings quickly

avoid heavy JSON encoding for huge maps

Keep DEBUG logs behind a build flag:

kDebugMode / kReleaseMode

In release:

default to INFO/WARN/ERROR only

allow dynamic tuning later if needed

8) Coding Rules for Copilot (strict)
When generating code:

Create AppLogger with:

debug/info/warn/error methods

consistent format output

optional metadata, corrId, error, stackTrace

Provide LogTag constants or enum.

Provide CorrelationId helper:

newId() returns short unique string

Never use print() directly in feature code.

Add examples:

login flow logs with corrId

network request logs with sanitized headers

Keep implementations small and testable.

9) Acceptance Checklist
A change is acceptable only if:

Logs are visible on PC using flutter logs or adb logcat

Log format matches the spec

CorrId exists for flows and is propagated

No secrets/PII are logged

Debug vs release behavior is respected


If you want, paste your current folder structure (`lib/…`) and I’ll adapt this file to your exact architecture (service-locator vs manual DI, feature boundaries, etc.).
::contentReference[oaicite:0]{index=0}