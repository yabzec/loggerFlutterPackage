# Logger

Logger that stores in D1 cloudflare database.
 
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

Setup a cloudflare databse with the following table named `log`

```sql
CREATE TABLE log (
    "id" integer PRIMARY KEY,
    "date" integer,
    "device" text,
    "os" text,
    "subject" text,
    "level" integer,
    "title" integer,
    "content" integer
)
```


Set up the following environment variables

- `CLOUDFLARE_ACCOUNT_ID`
- `CLOUDFLARE_LOGGER_DATABASE_ID`
- `CLOUDFLARE_API_TOKEN`

## Usage

Create an instance
```dart
final Logger logger = Logger('my_subject', 'my_title');
```

Log your stuff
```dart
logger.info('Your stuff');
logger.warn('Your stuff');
logger.error('Your stuff');
logger.critical('Your stuff');
```

## Tips
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/I3I61V3CIV)
