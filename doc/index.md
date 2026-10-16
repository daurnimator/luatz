## `luatz`

Requiring the base luatz module will give you a table of commonly used functions and submodules.

The table includes the following sub modules, which have their own documentation:

  - [`parse`](#parse): Parses common date/time formats
  - [`timetable`](#timetable): Class for date/time objects supporting normalisation

### `time()` <!-- --> {#luatz.time}

Returns the current unix timestamp using the most precise source available.
See [`gettime`](#gettime) for more information.


### `now()` <!-- --> {#luatz.now}

Returns the current time as a timetable object
See `timetable` for more information


### `get_tz([timezone_name])` <!-- --> {#luatz.get_tz}

Returns a timezone object (see `tzinfo` documentation) for the given `timezone_name`.
If `timezone_name` is `nil` then the local timezone is used.
If `timezone_name` is an absolute path, then that `tzinfo` file is used

This uses the local [zoneinfo database](https://www.iana.org/time-zones); 
names are usually of the form `Country/Largest_City` e.g. "America/New_York".
Check [wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) for an example list.


### `time_in(timezone_name[, utc_ts])` <!-- --> {#luatz.time_in}

Returns the time in seconds since 1970-01-01 0:00:00 in the given timezone as a number,
(same semantics as [`get_tz`](#luatz.get_tz)) at the given UTC time (defaults to now).


### `gmtime(ts)` <!-- --> {#luatz.gmtime}

Returns a normalised timetable for the given Unix timestamp in UTC.
Fields follow Lua's `os.date` conventions rather than C's `struct tm`:
`year` is the full year, `month` is 1–12, `day` is 1–31,
`hour` is 0–23, `min` is 0–59, `wday` is 1–7 (Sunday is 1),
and `yday` is 1–366. The `sec` field preserves fractional seconds.


### `localtime(ts)` <!-- --> {#luatz.localtime}

As in the C standard library


### `ctime(ts)` <!-- --> {#luatz.ctime}

As in the C standard library
