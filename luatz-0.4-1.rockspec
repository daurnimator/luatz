package = "luatz"
version = "0.4-1"

description = {
	summary = "library for time and date manipulation.";
	detailed = [[
	A lua library for time and date manipulation.

	Features include:
	  - Normalisation of broken down date objects
	    - allows for complex time/date manipulation logic e.g. "what day is it in 2 days, 5 hours from now?"
	  - Conversion between locations (time zones) using your local zoneinfo database.
	  - strftime style formatting

	All operations are possible without C extensions, though if available they may be used to increase accuracy.
	]];
	license = "MIT";
}

dependencies = {
	"lua >= 5.1";
}

source = {
	url = "https://github.com/daurnimator/luatz/archive/v0.4.tar.gz";
	dir = "luatz-0.4";
}

build = {
	type = "builtin";
	modules = {
		["luatz.init"]      = "luatz/init.lua";
		["luatz.gettime"]   = "luatz/gettime.lua";
		["luatz.parse"]     = "luatz/parse.lua";
		["luatz.timetable"] = "luatz/timetable.lua";
		["luatz.strftime"]  = "luatz/strftime.lua";
		["luatz.tzcache"]   = "luatz/tzcache.lua";
		["luatz.tzfile"]    = "luatz/tzfile.lua";
		["luatz.tzinfo"]    = "luatz/tzinfo.lua";
	};
}
