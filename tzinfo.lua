local tz_info_methods = { }
local tz_info_mt = {
	__index = tz_info_methods ;
}

-- Binary search
local function _find_current ( tzinfo , target , i , j )
	if i >= j then return j end

	local half = math.ceil ( (j+i) / 2 )

	if target > tzinfo [ half ].transition_time then
		return _find_current ( tzinfo , target , half , j )
	else
		return _find_current ( tzinfo , target , i , half-1 )
	end
end
function tz_info_methods:find_current ( current )
	return self [ _find_current ( self , current , 0 , #self ) ].info
end

function tz_info_methods:localize ( utc_ts )
	utc_ts = utc_ts or gettime ( )
	return utc_ts + self:find_current ( utc_ts ).gmtoff
end

return {
	tz_info_mt = tz_info_mt ;
}
