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

	it ( "#normalise handles fractional #month" , function ( )
		assert.same ( { timetable.normalise(2014,14.5,1,0,0,0) } , { 2015,2,15,0,0,0 } )
		assert.same ( { timetable.normalise(2015,14.5,1,0,0,0) } , { 2016,2,15,12,0,0 } ) -- leap year, so hours is 12
		assert.same ( { timetable.normalise(2016,14.5,1,0,0,0) } , { 2017,2,15,0,0,0 } )
	end )

	local function round_trip_add(t, field, x)
		local before = t:clone()
		t[field]=t[field]+x;
		t:normalise();
		t[field]=t[field]-x;
		t:normalise();
		assert.same(0, t-before)
	end
	it ( "#normalise round trips" , function ( )
		round_trip_add(timetable.new(2000,2,28,0,0,0), "month", 0.5)
		round_trip_add(timetable.new(2014,8,28,19,23,0), "month", 0.4)
		round_trip_add(timetable.new(2014,14.5,28,0,0,0), "month", 0.4)
	end )

	it("#rfc_3339 doesn't round seconds up to 60 (issue #4)", function()
		assert.same("2014-11-04T22:55:59.999", timetable.new_from_timestamp(1415141759.999911111):rfc_3339())
		assert.same("1970-01-01T00:00:59.999", timetable.new_from_timestamp(59.9999999):rfc_3339())
		assert.same("1969-12-31T23:59:59.999", timetable.new_from_timestamp(-0.001):rfc_3339())
		assert.same("1969-12-31T23:59:00.000", timetable.new_from_timestamp(-59.9999999):rfc_3339())
	end)
end )
