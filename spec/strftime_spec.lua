local luatz = require "luatz.init"
local time = 1234567890
describe("strftime", function()
	local strftime = luatz.strftime.strftime
	for i, spec in ipairs {
		"a", "A", "b", "B", "c", "C", "d", "D", "e", "F",
		"g", "G", "H", "I", "j", "m", "M", "n", "p", "r",
		"R", --[["s",]] "S", "t", "T", "u", "U", "V", "w", "W",
		"y", "Y", "z", "Z" , "%"
	} do
		local tt = luatz.gmtime(time)
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
