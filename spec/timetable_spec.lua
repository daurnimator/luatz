describe ( "Time table library" , function ( )
	local timetable = require "timetable"

	it ( "Doomsday calculation" , function ( )
		local doomsday = timetable.doomsday

		-- Doomsday in Gregorian calendar for 2013 is Thursday.
		assert.are.same ( 5 , doomsday(2013) )

		assert.are.same ( 3 , doomsday(1967) )
		assert.are.same ( 5 , doomsday(1968) )
	end )

	it ( "Get day of week correct" , function ( )
		local function native_normalise ( tbl )
			return os.date("*t",os.time(tbl))
		end
		local tbl = {
			year = 2013 ;
			month = 7 ;
			day = 23 ;
		}
		assert.are.same ( native_normalise ( tbl ).wday  , timetable.normalise ( tbl ).wday )
		tbl.day=24
		assert.are.same ( native_normalise ( tbl ).wday  , timetable.normalise ( tbl ).wday )
		tbl.day=25
		assert.are.same ( native_normalise ( tbl ).wday  , timetable.normalise ( tbl ).wday )
		tbl.day=26
		assert.are.same ( native_normalise ( tbl ).wday  , timetable.normalise ( tbl ).wday )
		tbl.day=27
		assert.are.same ( native_normalise ( tbl ).wday  , timetable.normalise ( tbl ).wday )
		tbl.day=28
		assert.are.same ( native_normalise ( tbl ).wday  , timetable.normalise ( tbl ).wday )
		tbl.day=29
		assert.are.same ( native_normalise ( tbl ).wday  , timetable.normalise ( tbl ).wday )
	end )
end )
