local _M = { }

_M.source , _M.resolution , _M.gettime = (function()
	local has_syscall , syscall = pcall ( require , "syscall" )
	if has_syscall then
		if syscall.clock_gettime then
			local clock_id = syscall.c.CLOCK.REALTIME
			local function timespec_to_number ( timespec )
				return tonumber ( timespec.tv_sec ) + tonumber ( timespec.tv_nsec ) * 1e-9
			end
			return "syscall.clock_gettime(CLOCK_REALTIME)" ,
				syscall.clock_getres and timespec_to_number ( syscall.clock_getres ( clock_id ) ) or 1e-9 ,
				function ( )
					return timespec_to_number ( syscall.clock_gettime ( clock_id ) )
				end

		elseif syscall.gettimeofday then
			local function timeval_to_number ( timeval )
				return tonumber ( timeval.tv_sec ) + tonumber ( timeval.tv_nsec ) * 1e-6
			end
			return "syscall.gettimeofday()" , 1e-6 ,
				function ( )
					return timeval_to_number ( syscall.gettimeofday ( ) )
				end
		end
	end

	local has_socket , socket = pcall ( require , "socket" )
	if has_socket and socket.gettime then
		-- on windows, this uses GetSystemTimeAsFileTime, which has resolution of 1e-7
		-- on linux, this uses gettimeofday, which has resolution of 1e-6
		return "socket.gettime()" , 1e-6 , socket.gettime
	end

	if ngx and ngx.now then
		return "ngx.now()" , 1e-3 , ngx.now
	end

	return "os.time()" , 1 , os.time
end)()

return _M
