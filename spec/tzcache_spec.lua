describe("Opening/reading system files", function()
	local tzcache = require "luatz.tzcache"
	it("should have a localtime", function()
		tzcache.get_tz()
	end)
	it("should be able to open UTC", function()
		tzcache.get_tz("UTC")
	end)
	it("should re-use results from cache", function()
		-- If cached it should return the same table
		local localtime = tzcache.get_tz()
		assert.are.equal(localtime, tzcache.get_tz())
		-- Once cache is cleared it should return a new table
		tzcache.clear_tz_cache()
		assert._not.equal(localtime, tzcache.get_tz())
	end)
end)
