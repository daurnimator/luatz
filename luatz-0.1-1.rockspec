package = "luatz"
version = "0.1-1"
source = {
   url = "https://github.com/daurnimator/luatz/archive/v0.1-1.tar.gz",
   dir = "luatz-0.1-1",
}
description = {
   summary = "This is a lua library for time and date manipulation.",
   detailed = [[
		This is a lua library for time and date manipulation.

		Importantly, it allows you to convert time between locations (time zones).
	]],
   license = "MIT/X11"
}
dependencies = {
   "lua >= 5.1", "lua < 5.3"
}
build = {
   type = "builtin",
   modules = {
      ['luatz.gettime'] = "luatz/gettime.lua",
      ['luatz.init'] = "luatz/init.lua",
      ['luatz.parse'] = "luatz/parse.lua",
      ['luatz.timetable'] = "luatz/timetable.lua",
      ['luatz.tzcache'] = "luatz/tzcache.lua",
      ['luatz.tzfile'] = "luatz/tzfile.lua",
      ['luatz.tzinfo'] = "luatz/tzinfo.lua"
   }
}
