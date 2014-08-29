--[[
Re-implementation of `os.date` from the standard lua library
]]

local gettime = require "luatz.gettime".gettime
local new_from_timestamp = require "luatz.timetable".new_from_timestamp
local get_tz = require "luatz.tzcache".get_tz

local function os_date ( format_string , timestamp )
	format_string = format_string or "%c"
	timestamp = timestamp or gettime ( )
	if format_string:sub ( 1 , 1 ) == "!" then -- UTC
		format_string = format_string:sub ( 2 )
	else -- Localtime
		timestamp = get_tz ( ):localise ( timestamp )
	end
	local tt = new_from_timestamp ( timestamp )
	if format_string == "*t" then
		return tt
	else
		return tt:strftime ( format_string )
	end
end

return os_date
