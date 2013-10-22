local get_tz = require "luatz.tzcache".get_tz

local function gettimein ( tz , now )
	return get_tz ( tz ):localize ( now )
end

return {
	get_tz    = get_tz ;
	gettime   = require "luatz.gettime".gettime ;
	gettimein = gettimein ;
	parse     = require "luatz.parse" ;
	timetable = require "luatz.timetable" ;
}
