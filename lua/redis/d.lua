local res = redis.call('GET', KEYS[1]);

if res ~= nil then
  res = tonumber(res);
  if res ~= nil and res > tonumber(ARGV[1]) then
      res = redis.call('DECR', KEYS[1]);
  end
end

return res" 1 foo 100

