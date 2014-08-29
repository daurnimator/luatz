describe ( "Timetable library" , function ( )
	local timetable = require "luatz.timetable"

	local function native_normalise ( year , month , day )
		return os.date("*t",os.time{
			year = year ;
			month = month ;
			day = day ;
		})
	end

	it ( "#normalise gets #wday (day of week) correct" , function ( )

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
		assert_same_wday ( 2014 , 1 , 1 )
		assert_same_wday ( 2014 , 1 , 6 )
		assert_same_wday ( 2016 , 2 , 28 )
	end )

	local function native_timestamp ( year , month , day )
		return assert ( tonumber ( assert ( io.popen (
						string.format('date -u -d "%d-%d-%d" +%%s', year , month , day )
					) ):read "*l" ) )
	end

	it ( "#timestamp creation is valid" , function ( )
		for y=1950,2013 do
			for m=1,12 do
				assert.same ( native_timestamp ( y,m,1 ) , timetable.timestamp(y,m,1,0,0,0) )
			end
		end
	end )

	it ( "#normalise handles out of range #month" , function ( )
		assert.same ( { timetable.normalise(2013,0,1,0,0,0) } , { 2012,12,1,0,0,0 } )
	end )
end )
