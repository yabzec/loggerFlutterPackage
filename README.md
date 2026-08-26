# Logger

Logger that sends entries to the Cloudflare-hosted logger API.

The package no longer talks to D1 directly. It performs a `PUT /api/insert`
against the logger web app, authenticating with a Cloudflare Access service
token, so the database credentials never ship inside the app.

## Instaling

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  logger:
    git:
      url: https://github.com/yabzec/logger.git
      ref: main
```

Then run:

```bash
flutter pub get
```

## Setup

The `log` table lives in the web app's D1 database, not in your Flutter project:

```sql
CREATE TABLE log (
    "id" integer PRIMARY KEY,
    "date" integer,
    "device" text,
    "os" text,
    "subject" text,
    "level" integer,
    "title" text,
    "content" text
)
```

Create a Cloudflare Access **service token** (Zero Trust > Access > Service
Auth) and add a policy on the logger application with the action *Service Auth*
that allows it. You will get a client id ending in `.access` and a 64-character
client secret.

## Usage

Create an instance

```dart
final Logger logger = Logger(
  'my_subject',
  'my_title',
  clientId: const String.fromEnvironment('LOGGER_CLIENT_ID'),
  clientSecret: const String.fromEnvironment('LOGGER_CLIENT_SECRET'),
);
```

Passing the pair through `--dart-define` keeps it out of source control:

```bash
flutter build apk \
  --dart-define=LOGGER_CLIENT_ID=xxxxxxxx.access \
  --dart-define=LOGGER_CLIENT_SECRET=yyyyyyyy
```

Point `baseUrl` elsewhere to log against a local `wrangler dev` instance. The
`CF-Access-*` headers are ignored there, so any placeholder values will do:

```dart
final Logger logger = Logger(
  'my_subject',
  'my_title',
  clientId: 'unused',
  clientSecret: 'unused',
  baseUrl: 'http://127.0.0.1:8787',
);
```

Log your stuff

```dart
logger.info('Your stuff');
logger.warn('Your stuff');
logger.error('Your stuff');
logger.critical('Your stuff');
```

Each method also takes an optional error and stack trace, appended to the
content only when present:

```dart
try {
  ...
} catch (e, s) {
  logger.error('Something broke', e, s);
}
```

Nothing is sent in debug builds; `_log` writes to `dart:developer` and returns
early on `kDebugMode`.

Call `dispose()` when you are done, unless you supplied your own `httpClient`:

```dart
logger.dispose();
```

## Tips
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/I3I61V3CIV)
