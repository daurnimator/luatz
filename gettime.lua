local _M = { }

local has_socket , socket = pcall ( require , "socket" )
if has_socket then
	_M.gettime = socket.gettime
else
	_M.gettime = os.time
end

return _M
