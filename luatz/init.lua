local get_tz = require "luatz.tzcache".get_tz

local function time_in ( tz , now )
	return get_tz ( tz ):localize ( now )
end

return {
	get_tz    = get_tz ;
	time      = require "luatz.gettime".gettime ;
	time_in   = time_in ;
	parse     = require "luatz.parse" ;
	timetable = require "luatz.timetable" ;
}
