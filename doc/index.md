# `luatz`

Requiring the base luatz module will give you a table of commonly used functions and submodules.

The table includes the following sub modules, which have their own documentation:

  - `parse`: Parses common date/time formats
  - `timetable`: Class for date/time objects supporting normalisation


## `time ( )`

Returns the current unix timestamp using the most accurate source available.
See `gettime` for more information.


## `get_tz ( timezone_name )`

Returns a timezone object (see `tzinfo` documentation) for the given `timezone_name`.
This uses the local [zoneinfo database](https://www.iana.org/time-zones); 
names are usually of the form `Country/Largest_City`. 
Check [wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) for an example list.


## `time_in ( timezone_name [, utc_ts] )`

Returns the current time in seconds since 1970-01-01 0:00:00 in the given timezone
(as a string, e.g. "America/New_York") at the given UTC time (defaults to now).
