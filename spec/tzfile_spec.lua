describe("Opening/reading tz files", function()
	local tzfile = require "luatz.tzfile"
	it("should be able to open a version 3 file", function()
		-- The tz file for America/Godthab from 2015g
		-- One of the smallest tzif3 files I have
		tzfile.read_tzfile("spec/Godthab.tz")
	end)
end)
