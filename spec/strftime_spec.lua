local luatz = require "luatz.init"
local time = 1234567890
local base_tt = luatz.gmtime(time)
describe("#strftime works the same as os.date", function()
	local strftime = luatz.strftime.strftime
	for _, spec in ipairs {
		"a", "A", "b", "B", "c", "C", "d", "D", "e", "F",
		"g", "G", "H", "I", "j", "m", "M", "n", "p", "r",
		"R", --[["s",]] "S", "t", "T", "u", "U", "V", "w", "W",
		"y", "Y", "z", "Z" , "%"
	} do
		local tt = base_tt:clone()
		local f = "%"..spec
		local osdf = "!%"..spec
		it("format specifier '"..f.."' is equivalent to os.date('"..osdf.."')", function()
			for i=1, 365*12 do
				local t = time + 60*60*24*i
				tt.day = tt.day + 1
				tt:normalise ( )
				assert.are.same(os.date(osdf,t), strftime(f,tt))
			end
		end)
	end
end)
describe("#asctime", function()
	local asctime = luatz.strftime.asctime
	it("should format correctly", function()
		assert.are.same("Fri Feb 13 23:31:30 2009\n", asctime(base_tt))
	end)
end)
