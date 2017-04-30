#!/usr/bin/env lua52
for l in io.lines("/usr/share/zoneinfo/zone.tab") do
	local code, coordinates, tz, comment = l:match '(%S+)%s+(%S+)%s+(%S+)'

	if code ~= nil then
		if  string.find(code,"#") == nil and tz ~=nil then
		print ( tz )
		end
	end
end
