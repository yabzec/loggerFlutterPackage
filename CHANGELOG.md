## 0.1.0

**Breaking:** `Logger` now requires a Cloudflare Access service token.

* Log entries are sent with `PUT /api/insert` to the logger web app instead of
  being written straight to D1. Dropped the `cloudflare_d1` dependency in
  favour of `http`.
* The constructor takes required `clientId` and `clientSecret` named
  parameters, plus optional `baseUrl` (defaults to `https://logger.yabzec.uk`)
  and `httpClient`. The `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_LOGGER_DATABASE_ID`
  and `CLOUDFLARE_API_TOKEN` environment variables are no longer read.
* `date` is still sent as epoch milliseconds, and the endpoint now stores it
  that way too, so new rows stay consistent with existing ones. The endpoint
  accepts an ISO 8601 string as well and normalises it to epoch milliseconds.
* The optional error and stack trace are appended to the content only when
  present. They previously produced a trailing `null\nnull` on every entry.
* Added `dispose()` to close the owned `http.Client`.

## 0.0.1

* TODO: Describe initial release.
