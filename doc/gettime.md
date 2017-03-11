## `luatz.gettime` <!-- --> {#gettime}

A module to get the current time.

Uses the most precise method available (in order:)

  - Use [ljsyscall](http://www.myriabit.com/ljsyscall/) to access `clock_gettime(2)` called with `CLOCK_REALTIME`
  - [lunix](http://25thandclement.com/~william/projects/lunix.html)'s `unix.clock_gettime()` (Only on non-Apple systems)
  - Use [ljsyscall](http://www.myriabit.com/ljsyscall/) to access `gettimeofday(2)`
  - [lunix](http://25thandclement.com/~william/projects/lunix.html)'s `unix.gettimeofday()`
  - [luasocket](http://w3.impa.br/~diego/software/luasocket/)'s `socket.gettime`
  - [Openresty](http://openresty.org/)'s [`ngx.now`](http://wiki.nginx.org/HttpLuaModule#ngx.now)
  - [`os.time`](http://www.lua.org/manual/5.3/manual.html#pdf-os.time)

### `source` <!-- --> {#gettime.source}

The library/function currently in use by [`gettime()`](#gettime.gettime).


### `resolution` <!-- --> {#gettime.resolution}

The smallest time resolution (in seconds) available from [`gettime()`](#gettime.gettime).


### `gettime()` <!-- --> {#gettime.gettime}

Returns the number of seconds since unix epoch (1970-01-01T00:00:00Z) as a lua number
