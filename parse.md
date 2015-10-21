# `luatz.parse`

Provides parsers for common time and date formats.

Functions take the source string and an optional initial postition.

### `rfc_3339 ( string [, init] )`

If the string is a valid RFC-3339 timestamp,
returns a luatz timetable and the (optional) time zone offset in seconds.

Otherwise returns `nil` and an error message
