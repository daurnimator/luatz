describe("Local time conversion", function()
	local luatz = require "luatz"
	local tzfile = require "luatz.tzfile"
	local timezone

	setup(function()
		-- A self-contained TZif v1 fixture with the 2024 New York transitions:
		-- March 10 at 07:00 UTC to EDT, November 3 at 06:00 UTC to EST.
		local fd = assert(io.tmpfile())
		fd:write("TZif", ("\0"):rep(16),
			string.char(0,0,0,2, 0,0,0,2, 0,0,0,0, 0,0,0,2, 0,0,0,2, 0,0,0,8),
			string.char(101,237,90,112, 103,39,17,96, 1,0),
			string.char(255,255,185,176,0,0, 255,255,199,192,1,4),
			"EST\0EDT\0", ("\0"):rep(4))
		fd:seek("set")
		timezone = tzfile.read_tz(fd)
		fd:close()
	end)

	local function utc(hour, min)
		return luatz.timetable.new(2024,11,3,hour,min,0):timestamp()
	end

	it("returns both UTC instants during the repeated hour", function()
		for _, minute in ipairs {0, 30, 59} do
			local first, second = timezone:utctime(luatz.timetable.new(2024,11,3,1,minute,0))
			assert.equal(utc(5,minute), first)
			assert.equal(utc(6,minute), second)
			assert.equal(utc(1,minute), timezone:localise(first))
			assert.equal(utc(1,minute), timezone:localise(second))
		end
	end)

	it("returns one instant outside the repeated hour", function()
		for _, case in ipairs {{0,59,4,59}, {2,0,7,0}, {2,30,7,30}} do
			local first, second = timezone:utctime(utc(case[1],case[2]))
			assert.equal(utc(case[3],case[4]), first)
			assert.is_nil(second)
		end
	end)
end)
