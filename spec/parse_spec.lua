describe("Time parsing library", function()
	local timetable = require "luatz.timetable"
	local parse = require "luatz.parse"

	it("applies the offset sign to both hours and minutes", function()
		local cases = {
			{"2024-01-15T12:00:00-03:30", -12600, "2024-01-15T15:30:00Z"};
			{"2024-01-15T12:00:00-00:30", -1800, "2024-01-15T12:30:00Z"};
			{"2024-01-15T12:00:00+05:30", 19800, "2024-01-15T06:30:00Z"};
		}
		for _, case in ipairs(cases) do
			local tt, offset = parse.rfc_3339(case[1])
			local utc = parse.rfc_3339(case[3])
			assert.equal(case[2], offset)
			assert.equal(utc:timestamp(), tt:timestamp() - offset)
		end
	end)

	it("#RFC3339 parsing", function()
		assert.same(timetable.new(2013,10,22,14,17,02), (parse.rfc_3339 "2013-10-22T14:17:02Z"))

		-- Numeric offsets accepted
		assert.same({timetable.new(2013,10,22,14,17,02), 10*3600 }, {parse.rfc_3339 "2013-10-22T14:17:02+10:00" })

		-- Missing offsets parse
		assert.same(timetable.new(2013,10,22,14,17,02), (parse.rfc_3339 "2013-10-22T14:17:02"))

		-- Fractional seconds (milliseconds) with Z suffix
		assert.same({timetable.new(2013,10,22,14,17,2.123), 0}, {parse.rfc_3339 "2013-10-22T14:17:02.123Z"})

		-- Fractional seconds with numeric offset
		assert.same({timetable.new(2013,10,22,14,17,2.456), -5*3600}, {parse.rfc_3339 "2013-10-22T14:17:02.456-05:00"})

		-- Invalid
		assert.same(nil, (parse.rfc_3339 "an invalid timestamp"))
	end)
end)
