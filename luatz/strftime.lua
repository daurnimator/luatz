local strformat = string.format
local floor = math.floor
local function idiv ( n , d )
	return floor ( n / d )
end

local c_locale = {
	abday = { "Sun" , "Mon" , "Tue" , "Wed" , "Thu" , "Fri" , "Sat" } ;
	day = { "Sunday" , "Monday" , "Tuesday" , "Wednesday" , "Thursday" , "Friday" , "Saturday" } ;
	abmon = { "Jan" , "Feb" , "Mar" , "Apr" , "May" , "Jun" , "Jul" , "Aug" , "Sep" , "Oct" , "Nov" , "Dec" } ;
	mon = { "January" , "February" , "March" , "April" , "May" , "June" , "July" , "August" , "September" , "October" , "November" , "December" } ;
	am_pm = { "AM" , "PM" } ;
}

--- ISO-8601 week logic
-- ISO 8601 weekday as number with Monday as 1 (1-7)
local function iso_8601_weekday ( wday )
	if wday == 1 then
		return 7
	else
		return wday - 1
	end
end
local iso_8601_week do
	-- Years that have 53 weeks according to ISO-8601
	local long_years = { }
	for i, v in ipairs {
		  4,   9,  15,  20,  26,  32,  37,  43,  48,  54,  60,  65,  71,  76,  82,
		 88,  93,  99, 105, 111, 116, 122, 128, 133, 139, 144, 150, 156, 161, 167,
		172, 178, 184, 189, 195, 201, 207, 212, 218, 224, 229, 235, 240, 246, 252,
		257, 263, 268, 274, 280, 285, 291, 296, 303, 308, 314, 320, 325, 331, 336,
		342, 348, 353, 359, 364, 370, 376, 381, 387, 392, 398
	} do
		long_years [ v ] = true
	end
	local function is_long_year ( year )
		return long_years [ year % 400 ]
	end
	function iso_8601_week ( self )
		local wday = iso_8601_weekday ( self.wday )
		local n = self.yday - wday
		local year = self.year
		if n < -3 then
			year = year - 1
			if is_long_year ( year ) then
				return year , 53 , wday
			else
				return year , 52 , wday
			end
		elseif n >= 361 and not is_long_year ( year ) then
			return year + 1 , 1 , wday
		else
			return year , idiv ( n + 10 , 7 ) , wday
		end
	end
end

--- Specifiers
local t = { }
function t:a ( locale )
	return "%s" , locale.abday [ self.wday ]
end
function t:A ( locale )
	return "%s" , locale.day [ self.wday ]
end
function t:b ( locale )
	return "%s" , locale.abmon [ self.month ]
end
function t:B ( locale )
	return "%s" , locale.mon [ self.month ]
end
function t:c ( locale )
	return "%.3s %.3s%3d %.2d:%.2d:%.2d %d" ,
		locale.abday [ self.wday ] , locale.abmon [ self.month ] ,
		self.day , self.hour , self.min , self.sec , self.year
end
-- Century
function t:C ( )
	return "%02d" , idiv ( self.year , 100 )
end
function t:d ( )
	return "%02d" , self.day
end
-- Short MM/DD/YY date, equivalent to %m/%d/%y
function t:D ( )
	return "%02d/%02d/%02d" , self.month , self.day , self.year % 100
end
function t:e ( )
	return "%2d" , self.day
end
-- Short YYYY-MM-DD date, equivalent to %Y-%m-%d
function t:F ( )
	return "%d-%02d-%02d" , self.year , self.month , self.day
end
-- Week-based year, last two digits (00-99)
function t:g ( )
	return "%02d" , iso_8601_week ( self ) % 100
end
-- Week-based year
function t:G ( )
	return "%d" , iso_8601_week ( self )
end
t.h = t.b
function t:H ( )
	return "%02d" , self.hour
end
function t:I ( )
	return "%02d" , (self.hour-1) % 12 + 1
end
function t:j ( )
	return "%03d" , self.yday
end
function t:m ( )
	return "%02d" , self.month
end
function t:M ( )
	return "%02d" , self.min
end
-- New-line character ('\n')
function t:n ( )
	return "\n"
end
function t:p ( locale )
	return self.hour < 12 and locale.am_pm[1] or locale.am_pm[2]
end
-- TODO: should respect locale
function t:r ( locale )
	return "%02d:%02d:%02d %s" ,
		(self.hour-1) % 12 + 1 , self.min , self.sec ,
		self.hour < 12 and locale.am_pm[1] or locale.am_pm[2]
end
-- 24-hour HH:MM time, equivalent to %H:%M
function t:R ( )
	return "%02d:%02d" , self.hour , self.min
end
function t:s ( )
	return "%d" , self:timestamp ( )
end
function t:S ( )
	return "%02d" , self.sec
end
-- Horizontal-tab character ('\t')
function t:t ( )
	return "\t"
end
-- ISO 8601 time format (HH:MM:SS), equivalent to %H:%M:%S
function t:T ( )
	return "%02d:%02d:%02d" , self.hour , self.min , self.sec
end
function t:u ( )
	return "%d" , iso_8601_weekday ( self.wday )
end
-- Week number with the first Sunday as the first day of week one (00-53)
function t:U ( )
	return "%02d" , idiv ( self.yday - self.wday + 7 , 7 )
end
-- ISO 8601 week number (00-53)
function t:V ( )
	return "%02d" , select ( 2 , iso_8601_week ( self ) )
end
-- Weekday as a decimal number with Sunday as 0 (0-6)
function t:w ( )
	return "%d" , self.wday - 1
end
-- Week number with the first Monday as the first day of week one (00-53)
function t:W ( )
	return "%02d" , idiv ( self.yday - iso_8601_weekday ( self.wday ) + 7 , 7 )
end
-- TODO make t.x and t.X respect locale
t.x = t.D
t.X = t.T
function t:y ( )
	return "%02d" , self.year % 100
end
function t:Y ( )
	return "%d" , self.year
end
-- TODO timezones
function t:z ( )
	return "+0000"
end
function t:Z ( )
	return "GMT"
end
-- A literal '%' character.
t["%"] = function ( self )
	return "%%"
end

local function strftime ( format_string , timetable )
	return ( string.gsub ( format_string , "%%([EO]?)(.)" , function ( locale_modifier , specifier )
		local func = t [ specifier ]
		if func then
			return strformat ( func ( timetable , c_locale ) )
		else
			error ( "invalid conversation specifier '%"..locale_modifier..specifier.."'" , 3 )
		end
	end ) )
end

local function asctime ( timetable )
	-- Equivalent to the format string "%c\n"
	return strformat ( t.c ( timetable , c_locale ) ) .. "\n"
end

return {
	strftime = strftime ;
	asctime = asctime ;
}
