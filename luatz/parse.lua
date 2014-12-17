local new_timetable = require "luatz.timetable".new

--- Parse an RFC 3339 datetime at the given position
-- Returns a time table and the `tz_offset`
-- Return value is not normalised (this preserves a leap second)
-- If the timestamp is only partial (i.e. missing "Z" or time offset) then `tz_offset` will be nil
-- TODO: Validate components are within their boundarys (e.g. 1 <= month <= 12)
local function rfc_3339 ( str , init )
	local year , month , day , hour , min , sec , patt_end = str:match ( "^(%d%d%d%d)%-(%d%d)%-(%d%d)[Tt](%d%d%.?%d*):(%d%d):(%d%d)()" , init )
	if not year then
		error ( "Invalid RFC 3339 timestamp" )
	end
	year  = tonumber ( year )
	month = tonumber ( month )
	day   = tonumber ( day )
	hour  = tonumber ( hour )
	min   = tonumber ( min )
	sec   = tonumber ( sec )

	local tt = new_timetable ( year , month , day , hour , min , sec )

	local tz_offset
	if str:match ("^[Zz]" , patt_end ) then
		tz_offset = 0
	else
		local hour_offset , min_offset = str:match ( "^([+-]%d%d):(%d%d)" , patt_end )
		if hour_offset then
			tz_offset = tonumber ( hour_offset ) * 3600 + tonumber ( min_offset ) * 60
		else
			-- Invalid RFC 3339 timestamp offset (should be Z or (+/-)hour:min)
			-- tz_offset will be nil
		end
	end

	return tt , tz_offset
end

return {
	rfc_3339 = rfc_3339 ;
}
