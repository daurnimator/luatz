# `luatz.tzinfo`

Provides a metatable for the timezone class.

Created in `luatz.tzfile` and managed by `luatz.tzcache`;
a timezone object contains information about a timezone.
These objects are based on the information available in a "zoneinfo" file.

Timezone objects should be considered opaque and immutable;
so the following details can be skipped over.

------------------------------------------------------------------------------

The table contains a sequence of tables that describe the timezone at a given point
using a `transition_time`: the unix timestamp (in UTC) that this definition starts, and
a `tt_info` object.

A `tt_info` object contains information about a time offset;
and contains the following fields:

  - `gmtoff` (number) The offset from GMT (UTC) in seconds
  - `isdst` (boolean): If this change was declared as daylight savings
  - `abbrind` (number, abbreviation id)
  - `abbr` (string): short name for this gmt offset
  - `isstd` (boolean)
  - `isgmt` (boolean)


## `:find_current ( utc_ts )`

Returns the relevant `tt_info` object for the given UTC timestamp in the timezone.


## `:localise ( utc_ts )` and `:localize ( utc_ts )`

Convert the given UTC timestamp to the timezone.
Returns the number of seconds since unix epoch in the given timezone.


## `:utctime ( local_ts )`

Convert the given local timestamp (seconds since unix epoch in the time zone) to a UTC timestamp.
This may result in ambigous results, in which case multiple values are returned.

e.g. consider that when daylight savings rewinds your local clock from 3am to 2am there will be two 2:30ams.
