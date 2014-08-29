describe ( "Timetable library" , function ( )
	local timetable = require "luatz.timetable"

	local function native_normalise ( year , month , day )
		return os.date("*t",os.time{
			year = year ;
			month = month ;
			day = day ;
		})
	end

	it ( "#is_leap is correct" , function ( )
		assert.same ( false , timetable.is_leap ( 1 ) )
		assert.same ( false , timetable.is_leap ( 3 ) )
		assert.same ( true  , timetable.is_leap ( 4 ) )
		assert.same ( true  , timetable.is_leap ( 2000 ) )
		assert.same ( true  , timetable.is_leap ( 2004 ) )
		assert.same ( true  , timetable.is_leap ( 2012 ) )
		assert.same ( false , timetable.is_leap ( 2013 ) )
		assert.same ( false , timetable.is_leap ( 2014 ) )
		assert.same ( false , timetable.is_leap ( 2100 ) )
		assert.same ( true  , timetable.is_leap ( 2400 ) )
	end )

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
		assert_same_wday ( 2016 , 2 , 29 )
		assert_same_wday ( 2016 , 3 , 1 )
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

	it ( "#normalise handles out of range days in a year" , function ( )
		assert.same ( { timetable.normalise(2013,1,366,0,0,0) } , { 2014,1,1,0,0,0 } )
		assert.same ( { timetable.normalise(2013,1,400,0,0,0) } , { 2014,2,4,0,0,0 } )
		assert.same ( { timetable.normalise(2016,1,400,0,0,0) } , { 2017,2,3,0,0,0 } )
		assert.same ( { timetable.normalise(2015,1,430,0,0,0) } , { 2016,3,5,0,0,0 } )
		assert.same ( { timetable.normalise(2016,1,430,0,0,0) } , { 2017,3,5,0,0,0 } )
		assert.same ( { timetable.normalise(2000,1,10000,0,0,0) } , { 2027,5,18,0,0,0 } )
		assert.same ( { timetable.normalise(2000,1,10000000,0,0,0) } , { 29379,1,25,0,0,0 } )
	end )

	it ( "#normalise handles out of range days in a #month" , function ( )
		assert.same ( { timetable.normalise(2013,0,1,0,0,0) } , { 2012,12,1,0,0,0 } )
		assert.same ( { timetable.normalise(2013,42,1,0,0,0) } , { 2016,6,1,0,0,0 } )

		-- Correct behaviour around leap days
		assert.same ( { timetable.normalise(2012,2,52,0,0,0) } , { 2012,3,23,0,0,0 } )
		assert.same ( { timetable.normalise(2013,2,52,0,0,0) } , { 2013,3,24,0,0,0 } )

		assert.same ( { timetable.normalise(2012,3,-2,0,0,0) } , { 2012,2,26,0,0,0 } )
		assert.same ( { timetable.normalise(2013,3,-2,0,0,0) } , { 2013,2,27,0,0,0 } )

		-- Also when more fields are out of range
		assert.same ( { timetable.normalise(2013,42,52,0,0,0) } , { 2016,7,22,0,0,0 } )
		assert.same ( { timetable.normalise(2013,42,52,50,0,0) } , { 2016,7,24,2,0,0 } )
	end )
end )
