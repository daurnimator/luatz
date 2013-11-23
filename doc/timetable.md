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
14) to faciliate arithmetic operations on date components. `:normalise ( )` can be 
called to modify components to return to their standard range.

Equality and comparisons should work between timetable objects.


## `new ( year , month , day , hour , min , sec , [yday] , [wday] )`

Returns a new timetable with the given contents.


## `new_from_timestamp ( timestamp )`

Returns a new timetable given a timestamp in seconds since the unix epoch of 
1970-01-01.

`:normalise ( )` should probably be called before use to resolve to the current time and 
date.


## `:clone ( )`

Returns a new independant instance of an existing timetable object.


## `:normalise ( )`

Mutates the current object's time and date components so that they lie within 'normal' 
ranges e.g. `month` is `1`-`12`; `min` is `0`-`59`


## `:rfc_3339 ( )` and `__tostring` metamethod

Returns the timetable formatted as an rfc-3339 style string.
The timezone offset (or Z) is not appended.
The ranges of components are not checked, and if you want a valid timestamp, `:normalise 
( )` should be called first.


## `:timestamp ( )`

Returns the timetable as the number of seconds since unix epoch (1970-01-01) as a lua 
number.
