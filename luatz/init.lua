local _M = {
	parse = require "luatz.parse" ;
	strftime = require "luatz.strftime" ;
	timetable = require "luatz.timetable" ;
}

--- Top-level aliases for common functions

_M.time = require "luatz.gettime".gettime
_M.get_tz = require "luatz.tzcache".get_tz

--- Handy functions

_M.time_in = function ( tz , now )
	return _M.get_tz ( tz ):localize ( now )
end

return _M
