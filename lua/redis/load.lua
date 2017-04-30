redis-cli script load "

redis.call('SET', 'BOO', ARGV[1])

return 10+ARGV[1]
"

#  evalsha c13946dfd6c666f210c962d1617a56fdb388e118 1 0 5
# get BOO
