package = "luatz"
version = "scm-0"

description = {
	summary = "library for time and date manipulation." ;
	detailed = [[
	A lua library for time and date manipulation.

	Features include:
	  - Normalisation of broken down date objects
	    - allows for complex time/date manipulation logic e.g. "what day is it in 2 days, 5 hours from now?"
	  - Conversion between locations (time zones) using your local zoneinfo database.
	  - stftime style formatting

	All operations are possible without C extensions, though if available they may be used to increase accuracy.
	]] ;
	license = "MIT/X11" ;
}

dependencies = {
	"lua >= 5.1" ;
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
