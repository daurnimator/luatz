local strftime = require "luatz.strftime".strftime
local strformat = string.format
local floor = math.floor
local idiv do
	-- Try and use actual integer division when available (Lua 5.3+)
	local idiv_loader = (loadstring or load)([[return function(n,d) return n//d end]], "idiv") -- luacheck: ignore 113
	if idiv_loader then
		idiv = idiv_loader()
	else
		idiv = function(n, d)
			return floor(n/d)
		end
	end
end


local mon_lengths = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
-- Number of days in year until start of month; not corrected for leap years
local months_to_days_cumulative = { 0 }
for i = 2, 12 do
	months_to_days_cumulative [ i ] = months_to_days_cumulative [ i-1 ] + mon_lengths [ i-1 ]
end
-- For Sakamoto's Algorithm (day of week)
local sakamoto = {0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4};

local function is_leap ( y )
	if (y % 4) ~= 0 then
		return false
	elseif (y % 100) ~= 0 then
		return true
	else
		return (y % 400) == 0
	end
end

local function year_length ( y )
	return is_leap ( y ) and 366 or 365
end

local function month_length ( m , y )
	if m == 2 then
		return is_leap ( y ) and 29 or 28
	else
		return mon_lengths [ m ]
	end
end

local function leap_years_since ( year )
	return idiv ( year , 4 ) - idiv ( year , 100 ) + idiv ( year , 400 )
end

local function day_of_year ( day , month , year )
	local yday = months_to_days_cumulative [ month ]
	if month > 2 and is_leap ( year ) then
		yday = yday + 1
	end
	return yday + day
end

local function day_of_week ( day , month , year )
	if month < 3 then
		year = year - 1
	end
	return ( year + leap_years_since ( year ) + sakamoto[month] + day ) % 7 + 1
end

local function borrow ( tens , units , base )
	local frac = tens % 1
	units = units + frac * base
	tens = tens - frac
	return tens , units
end

local function carry ( tens , units , base )
	if units >= base then
		tens  = tens + idiv ( units , base )
		units = units % base
	elseif units < 0 then
		tens  = tens + idiv ( units , base )
		units = ( base + units ) % base
	end
	return tens , units
end

-- Modify parameters so they all fit within the "normal" range
local function normalise ( year , month , day , hour , min , sec )
	-- `month` and `day` start from 1, need -1 and +1 so it works modulo
	month , day = month - 1 , day - 1

	-- Convert everything (except seconds) to an integer
	-- by propagating fractional components down.
	year  , month = borrow ( year  , month , 12 )
	-- Carry from month to year first, so we get month length correct in next line around leap years
	year  , month = carry ( year , month , 12 )
	month , day   = borrow ( month , day   , month_length ( floor ( month + 1 ) , year ) )
	day   , hour  = borrow ( day   , hour  , 24 )
	hour  , min   = borrow ( hour  , min   , 60 )
	min   , sec   = borrow ( min   , sec   , 60 )

	-- Propagate out of range values up
	-- e.g. if `min` is 70, `hour` increments by 1 and `min` becomes 10
	-- This has to happen for all columns after borrowing, as lower radixes may be pushed out of range
	min   , sec   = carry ( min   , sec   , 60 ) -- TODO: consider leap seconds?
	hour  , min   = carry ( hour  , min   , 60 )
	day   , hour  = carry ( day   , hour  , 24 )
	-- Ensure `day` is not underflowed
	-- Add a whole year of days at a time, this is later resolved by adding months
	-- TODO[OPTIMIZE]: This could be slow if `day` is far out of range
	while day < 0 do
		month = month - 1
		if month < 0 then
			year = year - 1
			month = 11
		end
		day = day + month_length ( month + 1 , year )
	end
	year , month = carry ( year , month , 12 )

	-- TODO[OPTIMIZE]: This could potentially be slow if `day` is very large
	while true do
		local i = month_length ( month + 1 , year )
		if day < i then break end
		day = day - i
		month = month + 1
		if month >= 12 then
			month = 0
			year = year + 1
		end
	end

	-- Now we can place `day` and `month` back in their normal ranges
	-- e.g. month as 1-12 instead of 0-11
	month , day = month + 1 , day + 1

	return year , month , day , hour , min , sec
end

local leap_years_since_1970 = leap_years_since ( 1970 )
local function timestamp ( year , month , day , hour , min , sec )
	year , month , day , hour , min , sec = normalise ( year , month , day , hour , min , sec )

	local days_since_epoch = day_of_year ( day , month , year )
		+ 365 * ( year - 1970 )
		-- Each leap year adds one day
		+ ( leap_years_since ( year - 1 ) - leap_years_since_1970 ) - 1

	return days_since_epoch * (60*60*24)
		+ hour  * (60*60)
		+ min   * 60
		+ sec
end


local timetable_methods = { }

function timetable_methods:unpack ( )
	return assert ( self.year  , "year required" ) ,
		assert ( self.month , "month required" ) ,
		assert ( self.day   , "day required" ) ,
		self.hour or 12 ,
		self.min  or 0 ,
		self.sec  or 0 ,
		self.yday ,
		self.wday
end

function timetable_methods:normalise ( )
	local year , month , day
	year , month , day , self.hour , self.min , self.sec = normalise ( self:unpack ( ) )

	self.day   = day
	self.month = month
	self.year  = year
	self.yday  = day_of_year ( day , month , year )
	self.wday  = day_of_week ( day , month , year )

	return self
end
timetable_methods.normalize = timetable_methods.normalise -- American English

function timetable_methods:timestamp ( )
	return timestamp ( self:unpack ( ) )
end

function timetable_methods:rfc_3339 ( )
	local year, month, day, hour, min, fsec = self:unpack()
	local sec, msec = borrow(fsec, 0, 1000)
	msec = math.floor(msec)
	return strformat ( "%04u-%02u-%02uT%02u:%02u:%02d.%03d" , year , month , day , hour , min , sec , msec )
end

function timetable_methods:strftime ( format_string )
	return strftime ( format_string , self )
end

local timetable_mt

local function coerce_arg ( t )
	if getmetatable ( t ) == timetable_mt then
		return t:timestamp ( )
	end
	return t
end

timetable_mt = {
	__index    = timetable_methods ;
	__tostring = timetable_methods.rfc_3339 ;
	__eq = function ( a , b )
		return a:timestamp ( ) == b:timestamp ( )
	end ;
	__lt = function ( a , b )
		return a:timestamp ( ) < b:timestamp ( )
	end ;
	__sub = function ( a , b )
		return coerce_arg ( a ) - coerce_arg ( b )
	end ;
}

local function cast_timetable ( tm )
	return setmetatable ( tm , timetable_mt )
end

local function new_timetable ( year , month , day , hour , min , sec , yday , wday )
	return cast_timetable {
		year  = year ;
		month = month ;
		day   = day ;
		hour  = hour ;
		min   = min ;
		sec   = sec ;
		yday  = yday ;
		wday  = wday ;
	}
end

function timetable_methods:clone ( )
	return new_timetable ( self:unpack ( ) )
end

local function new_from_timestamp ( ts )
	if type ( ts ) ~= "number" then
		error ( "bad argument #1 to 'new_from_timestamp' (number expected, got " .. type ( ts ) .. ")" , 2 )
	end
	return new_timetable ( 1970 , 1 , 1 , 0 , 0 , ts ):normalise ( )
end

return {
	is_leap = is_leap ;
	day_of_year = day_of_year ;
	day_of_week = day_of_week ;
	normalise = normalise ;
	timestamp = timestamp ;

	new = new_timetable ;
	new_from_timestamp = new_from_timestamp ;
	cast = cast_timetable ;
	timetable_mt = timetable_mt ;
}
