local read_tzfile = require "luatz.tzfile".read_tzfile

local tz_cache = { }

local function name_to_zoneinfo_path ( name )
	if name then
		return "/usr/share/zoneinfo/" .. name
	else
		return "/etc/localtime"
	end
end

local function clear_tz_cache ( name )
	tz_cache [ name_to_zoneinfo_path ( name ) ] = nil
end

local function get_tz ( name )
	local path = name_to_zoneinfo_path ( name )
	local tzinfo = tz_cache [ path ]
	if tzinfo == nil then
		tzinfo = read_tzfile ( path )
		tz_cache [ path ] = tzinfo
	end
	return tzinfo
end

return {
	get_tz = get_tz ;
	clear_tz_cache = clear_tz_cache ;
}
