# `luatz.timetable`

Provides an class to represent a time and date.
Objects have no concept of timezone or utc offset.

The fields are intentionally compatible with the lua standard library's `os.date` and `os.time`. Objects have fields:

  - `year`
  - `month`
  - `day`
  - `hour`
  - `min`
  - `sec`
  - `yday` (optional)
  - `wday` (optional)
  
timetable components may be outside of their standard range (e.g. a month component of 
14) to facilitate arithmetic operations on date components. `:normalise ( )` can be 
called to modify components to return to their standard range.

Equality and comparisons should work between timetable objects.


### `new ( year , month , day , hour , min , sec , [yday] , [wday] )`

Returns a new timetable with the given contents.


### `new_from_timestamp ( timestamp )`

Returns a new (normalised) timetable, given a timestamp in seconds since the unix epoch of 
1970-01-01.


### `:clone ( )`

Returns a new independent instance of an existing timetable object.


### `:normalise ( )`

Mutates the current object's time and date components so that are integers within 'normal'
ranges e.g. `month` is `1`-`12`; `min` is `0`-`59`

First, fractional parts are propagated down.  
e.g. `.month=6.5` `.day=1` (which could be read as "the first day after the middle of June")
normalises to `.month=2` `.day=16`

Second, any fields outside of their normal ranges are propagated up  
e.g. `.hour=10` `.min=100` (100 minutes past 10am)
normalises to `.hour=11` `.min=40`


### `:rfc_3339 ( )` and `__tostring` metamethod

Returns the timetable formatted as an rfc-3339 style string.
The timezone offset (or Z) is not appended.
The ranges of components are not checked, if you want a valid timestamp,
`:normalise ( )` should be called first.


### `:timestamp ( )`

Returns the timetable as the number of seconds since unix epoch (1970-01-01) as a lua number.


### `:unpack ( )`

Unpacks the timetable object; returns `year`, `month`, `day`, `hour`, `min`, `sec`, `yday`, `wday`
