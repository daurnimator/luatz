local tz_info_mt = require "luatz.tzinfo".tz_info_mt
local tt_info_mt = require "luatz.tzinfo".tt_info_mt

local read_int32be, read_int64be

if string.unpack then -- Only available in Lua 5.3+
	function read_int32be(fd)
		local data, err = fd:read(4)
		if data == nil then return nil, err end
		return string.unpack(">i4", data)
	end

	function read_int64be(fd)
		local data, err = fd:read(8)
		if data == nil then return nil, err end
		return string.unpack(">i8", data)
	end
else
	function read_int32be(fd)
		local data, err = fd:read(4)
		if data == nil then return nil, err end
		local o1, o2, o3, o4 = data:byte(1, 4)

		local unsigned = o4 + o3*2^8 + o2*2^16 + o1*2^24
		if unsigned >= 2^31 then
			return unsigned - 2^32
		else
			return unsigned
		end
	end

	function read_int64be(fd)
		local data, err = fd:read(8)
		if data == nil then return nil, err end
		local o1, o2, o3, o4, o5, o6, o7, o8 = data:byte(1, 8)

		local unsigned = o8 + o7*2^8 + o6*2^16 + o5*2^24 + o4*2^32 + o3*2^40 + o2*2^48 + o1*2^56
		if unsigned >= 2^63 then
			return unsigned - 2^64
		else
			return unsigned
		end
	end
end

local function read_flags ( fd , n )
	local data , err = fd:read ( n )
	if data == nil then return nil , err end

	local res = { }
	for i=1, n do
		res[i] = data:byte(i,i) ~= 0
	end
	return res
end

local fifteen_nulls = ("\0"):rep(15)
local function read_tz ( fd )
	assert ( fd:read(4) == "TZif" , "Invalid TZ file" )
	local version = assert ( fd:read(1) )
	if version == "\0" or version == "2" or version == "3" then
		local MIN_TIME = -2^32+1

		assert ( assert ( fd:read(15) ) == fifteen_nulls , "Expected 15 nulls" )

		-- The number of UTC/local indicators stored in the file.
		local tzh_ttisgmtcnt = assert ( read_int32be ( fd ) )

		-- The number of standard/wall indicators stored in the file.
		local tzh_ttisstdcnt = assert ( read_int32be ( fd ) )

		-- The number of leap seconds for which data is stored in the file.
		local tzh_leapcnt = assert ( read_int32be ( fd ) )

		-- The number of "transition times" for which data is stored in the file.
		local tzh_timecnt = assert ( read_int32be ( fd ) )

		-- The number of "local time types" for which data is stored in the file (must not be zero).
		local tzh_typecnt = assert ( read_int32be ( fd ) )

		-- The number of characters of "timezone abbreviation strings" stored in the file.
		local tzh_charcnt = assert ( read_int32be ( fd ) )

		local transition_times = { }
		for i=1, tzh_timecnt do
			transition_times [ i ] = assert ( read_int32be ( fd ) )
		end
		local transition_time_ind = { assert ( fd:read ( tzh_timecnt ) ):byte ( 1 , -1 ) }

		local ttinfos = { }
		for i=1, tzh_typecnt do
			ttinfos [ i ] = {
				gmtoff = assert ( read_int32be ( fd ) ) ;
				isdst  = assert ( fd:read ( 1 ) ) ~= "\0" ;
				abbrind = assert ( fd:read ( 1 ) ):byte ( ) ;
			}
		end

		local abbreviations = assert ( fd:read ( tzh_charcnt ) )

		local leap_seconds = { }
		for i=1, tzh_leapcnt do
			leap_seconds [ i ] = {
				offset = assert ( read_int32be ( fd ) ) ;
				n = assert ( read_int32be ( fd ) ) ;
			}
		end

		local isstd = assert ( read_flags ( fd , tzh_ttisstdcnt ) )

		local isgmt = assert ( read_flags ( fd , tzh_ttisgmtcnt ) )

		local TZ

		if version == "2" or version == "3" then
			--[[
			For version-2-format timezone files, the above header and data is followed by a second header and data,
			identical in format except that eight bytes are used for each transition time or leap-second time.
			]]
			assert(fd:read(4) == "TZif")
			assert(fd:read(1) == version)
			assert ( assert ( fd:read(15) ) == fifteen_nulls , "Expected 15 nulls" )

			MIN_TIME = -2^64+1

			-- The number of UTC/local indicators stored in the file.
			tzh_ttisgmtcnt = assert ( read_int32be ( fd ) )

			-- The number of standard/wall indicators stored in the file.
			tzh_ttisstdcnt = assert ( read_int32be ( fd ) )

			-- The number of leap seconds for which data is stored in the file.
			tzh_leapcnt = assert ( read_int32be ( fd ) )

			-- The number of "transition times" for which data is stored in the file.
			tzh_timecnt = assert ( read_int32be ( fd ) )

			-- The number of "local time types" for which data is stored in the file (must not be zero).
			tzh_typecnt = assert ( read_int32be ( fd ) )

			-- The number of characters of "timezone abbreviation strings" stored in the file.
			tzh_charcnt = assert ( read_int32be ( fd ) )

			transition_times = { }
			for i=1, tzh_timecnt do
				transition_times [ i ] = assert ( read_int64be ( fd ) )
			end
			transition_time_ind = { assert ( fd:read ( tzh_timecnt ) ):byte ( 1 , -1 ) }

			ttinfos = { }
			for i=1, tzh_typecnt do
				ttinfos [ i ] = {
					gmtoff = assert ( read_int32be ( fd ) ) ;
					isdst  = assert ( fd:read ( 1 ) ) ~= "\0" ;
					abbrind = assert ( fd:read ( 1 ) ):byte ( ) ;
				}
			end

			abbreviations = assert ( fd:read ( tzh_charcnt ) )

			leap_seconds = { }
			for i=1, tzh_leapcnt do
				leap_seconds [ i ] = {
					offset = assert ( read_int64be ( fd ) ) ;
					n = assert ( read_int32be ( fd ) ) ;
				}
			end

			isstd = assert ( read_flags ( fd , tzh_ttisstdcnt ) )

			isgmt = assert ( read_flags ( fd , tzh_ttisgmtcnt ) )

			--[[
			After the second header and data comes a newline-enclosed, POSIX-TZ-environment-variable-style string
			for use in handling instants after the last transition time stored in the file
			(with nothing between the newlines if there is no POSIX representation for such instants).
			]]

			--[[
			For version-3-format time zone files, the POSIX-TZ-style string may
			use two minor extensions to the POSIX TZ format, as described in newtzset (3).
			First, the hours part of its transition times may be signed and range from
			-167 through 167 instead of the POSIX-required unsigned values
			from 0 through 24.  Second, DST is in effect all year if it starts
			January 1 at 00:00 and ends December 31 at 24:00 plus the difference
			between daylight saving and standard time.
			]]

			assert ( assert ( fd:read ( 1 ) ) == "\n" , "Expected newline at end of version 2 header" )

			TZ = assert ( fd:read ( "*l" ) )
			if #TZ == 0 then
				TZ = nil
			end
		end

		for i=1, tzh_typecnt do
			local v = ttinfos [ i ]
			v.abbr = abbreviations:sub ( v.abbrind+1 , v.abbrind+3 )
			v.isstd = isstd [ i ] or false
			v.isgmt = isgmt [ i ] or false
			setmetatable ( v , tt_info_mt )
		end

		--[[
		Use the first standard-time ttinfo structure in the file
		(or simply the first ttinfo structure in the absence of a standard-time structure)
		if either tzh_timecnt is zero or the time argument is less than the first transition time recorded in the file.
		]]
		local first = 1
		do
			for i=1, tzh_ttisstdcnt do
				if isstd[i] then
					first = i
					break
				end
			end
		end

		local res = {
			future = TZ;
			[0] = {
				transition_time = MIN_TIME ;
				info = ttinfos [ first ] ;
			}
		}
		for i=1, tzh_timecnt do
			res [ i ] = {
				transition_time = transition_times [ i ] ;
				info = ttinfos [ transition_time_ind [ i ]+1 ] ;
			}
		end
		return setmetatable ( res , tz_info_mt )
	else
		error ( "Unsupported version" )
	end
end

local function read_tzfile ( path )
	local fd = assert ( io.open ( path , "rb" ) )
	local tzinfo = read_tz ( fd )
	fd:close ( )
	return tzinfo
end

return {
	read_tz = read_tz ;
	read_tzfile = read_tzfile ;
}
