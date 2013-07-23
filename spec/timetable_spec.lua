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
		local function native_normalise ( year , month , day )
			return os.date("*t",os.time{
				year = year ;
				month = month ;
				day = day ;
			})
		end
		local function assert_same_wday ( year , month , day )
			return assert.are.same (
				native_normalise ( year , month , day ).wday ,
				timetable.new ( year , month , day ):normalise().wday
			)
		end

		assert_same_wday ( 2013 , 7 , 23 )
		assert_same_wday ( 2013 , 7 , 24 )
		assert_same_wday ( 2013 , 7 , 25 )
		assert_same_wday ( 2013 , 7 , 26 )
		assert_same_wday ( 2013 , 7 , 27 )
		assert_same_wday ( 2013 , 7 , 28 )
		assert_same_wday ( 2013 , 7 , 29 )
	end )
end )
