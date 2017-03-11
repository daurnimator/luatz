local gettime = require "luatz.gettime".gettime
local timetable_mt = require "luatz.timetable".timetable_mt

local function to_timestamp ( o )
	if type ( o ) == "number" then
		return o
	elseif getmetatable ( o ) == timetable_mt then
		return o:timestamp ( )
	end
end

local tz_info_methods = { }
local tz_info_mt = {
	__name = "luatz.tz_info";
	__index = tz_info_methods ;
}
local tt_info_mt = {
	__name = "luatz.tt_info";
	__tostring = function ( self )
		return string.format ( "tt_info:%s=%d" , self.abbr , self.gmtoff )
	end ;
}

-- Binary search
local function _find_current ( tzinfo , target , i , j )
	if i >= j then return j end

	local half = math.ceil ( (j+i) / 2 )

	if target >= tzinfo [ half ].transition_time then
		return _find_current ( tzinfo , target , half , j )
	else
		return _find_current ( tzinfo , target , i , half-1 )
	end
end

local function find_current_local ( tzinfo , ts_local )
	-- Find two best possibilities by searching back and forward a day (assumes transition is never by more than 24 hours)
	local tz_first = _find_current ( tzinfo , ts_local-86400 , 0 , #tzinfo )
	local tz_last  = _find_current ( tzinfo , ts_local+86400 , 0 , #tzinfo )

	local n_candidates = tz_last - tz_first + 1

	if n_candidates == 1 then
		return tz_first
	elseif n_candidates == 2 then
		local tz_first_ob = tzinfo [ tz_first ]
		local tz_last_ob  = tzinfo [ tz_last ]

		local first_gmtoffset = tz_first_ob.info.gmtoff
		local last_gmtoffset  = tz_last_ob .info.gmtoff

		local t_start = tz_last_ob.transition_time + first_gmtoffset
		local t_end   = tz_last_ob.transition_time + last_gmtoffset

		-- If timestamp is before start or after end
		if ts_local < t_start then
			return tz_first
		elseif ts_local > t_end then
			return tz_last
		end

		-- If we get this far, the local time is ambiguous
		return tz_first , tz_last
	else
		error ( "Too many transitions in a 2 day period" )
	end
end

function tz_info_methods:find_current ( current )
	current = assert ( to_timestamp ( current ) , "invalid timestamp to :find_current" )
	return self [ _find_current ( self , current , 0 , #self ) ].info
end

function tz_info_methods:localise ( utc_ts )
	utc_ts = utc_ts or gettime ( )
	return utc_ts + self:find_current ( utc_ts ).gmtoff
end
tz_info_methods.localize = tz_info_methods.localise

function tz_info_methods:utctime ( ts_local )
	ts_local = assert ( to_timestamp ( ts_local ) , "invalid timestamp to :utctime" )
	local tz1 , tz2 = find_current_local ( self , ts_local )
	tz1 = self [ tz1 ].info
	if tz2 == nil then
		return ts_local - tz1.gmtoff
	else -- Local time is ambiguous
		tz2 = self [ tz2 ].info

		return ts_local - tz2.gmtoff , ts_local - tz2.gmtoff
	end
end

return {
	tz_info_mt = tz_info_mt ;
	tt_info_mt = tt_info_mt ;
}
