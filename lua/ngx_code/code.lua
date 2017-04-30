#!/usr/bin/env lua52

local codes = {}
local req = {}

total = 0

for l in io.lines("/acc") do
	-- 78.37.167.66    [12/Nov/2015:02:29:24 +0300]    404     10.0.0.180:8081 404     test.iqoption.com       GET /adafa HTTP/1.1     -       Mozilla/5.0 (X11; FreeBSD amd64; rv:41.0) Gecko/20100101 Firefox/41.0   -       78.37.167.66    -       0.000-0.000     RU      [-]
	local ip, date, a, b, c, d, e, f, g, h, j = l:match '(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)'

--	print ( b )
-- --	print ( d )
--	print ( f )

	b = tonumber(b)

	codes[b] = (codes[b] or 0) + 1
	req[f] = (req[f] or 0) + 1

	if f == "GET" or f == "POST" then total = total + 1 end

end

-- print ( "Summary:" )
--print ( "Code 200: " .. code_200 )
-- print ( "Code 404: " .. code_404 )

print "--- Summary ---\n"
print ( "By codes:" )
for w, sum in pairs(codes) do
	print ( w .. ": " .. sum )
end

print ""
print ( "By requests:" )
for w, sum in pairs(req) do
	print ( w .. ": " .. sum )
end

print ""
print ( "Total: " .. total )

