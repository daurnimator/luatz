local read_tzfile = require "luatz.tzfile".read_tzfile

local base_zoneinfo_path = "/usr/share/zoneinfo/"
local local_zoneinfo_path = "/etc/localtime"
local tz_cache = { }

local function name_to_zoneinfo_path ( name )
	if name then
		return base_zoneinfo_path .. name
	else
		return local_zoneinfo_path
	end
end

local function clear_tz_cache ( name )
	tz_cache [ name_to_zoneinfo_path ( name ) ] = nil
end

local function get_tz ( name )
	local path = name_to_zoneinfo_path ( name )
	-- TODO: stat path
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
