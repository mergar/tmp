#!/usr/local/bin/lua52

local database = { }
for l in io.lines("/usr/share/zoneinfo/zone.tab") do
	local code, coordinates, tz, comment = l:match '(%S+)%s+(%S+)%s+(%S+)'
	table.insert(database, { name = n, address = a, email = e })

	if code ~= nil then
		if  string.find(code,"#") == nil and tz ~=nil then
		table.insert(database, { code = code, tz = tz })
		end
	end
end

function compare(a,b)
	return a[1] < b[1]
end

-- table.sort(database,compare)


for i,n in pairs(database) do
	table.sort(n)
	for x,y in pairs(n) do
		if x == "tz" then print(y)
--		elseif x == "code" then print(y)
		end
	end
end


