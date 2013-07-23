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
   "lua ~> 5.1" ;
}

source = {
	url = "git://github.com/daurnimator/luatz.git" ;
}

build = {
	type = "builtin" ;
	modules = {
		["luatz.init"]      = "src/init.lua" ;
		["luatz.gettime"]   = "src/gettime.lua" ;
		["luatz.timetable"] = "src/timetable.lua" ;
		["luatz.tzcache"]   = "src/tzcache.lua" ;
		["luatz.tzfile"]    = "src/tzfile.lua" ;
		["luatz.tzinfo"]    = "src/tzinfo.lua" ;
	} ;
}
