package = "luatz"
version = "scm-0"

description = {
	summary = "This is a lua library for time and date manipulation." ;
	detailed = [[
		This is a lua library for time and date manipulation.

		Importantly, it allows you to convert time between locations (time zones).
	]] ;
	license = "MIT/X11" ;
}

dependencies = {
	"lua >= 5.1" ;
	"lua < 5.3" ;
}

source = {
	url = "git://github.com/daurnimator/luatz.git" ;
}

build = {
	type = "builtin" ;
	modules = {
		["luatz.init"]      = "luatz/init.lua" ;
		["luatz.gettime"]   = "luatz/gettime.lua" ;
		["luatz.parse"]     = "luatz/parse.lua" ;
		["luatz.timetable"] = "luatz/timetable.lua" ;
		["luatz.strftime"]  = "luatz/strftime.lua" ;
		["luatz.tzcache"]   = "luatz/tzcache.lua" ;
		["luatz.tzfile"]    = "luatz/tzfile.lua" ;
		["luatz.tzinfo"]    = "luatz/tzinfo.lua" ;
	} ;
}
