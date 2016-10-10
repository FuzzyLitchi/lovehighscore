local socket = require "socket"

local udp = socket.udp()

udp:settimeout(0)
udp:setsockname('*', 7788)

local update
local data, msg_or_ip, port_or_nil
local entity, cmd, parms
local running = true

print "Beginning server loop."

while running do
	data, msg_or_ip, port_or_nil = udp:receivefrom()
	if data then
    if data=="update" then

    else
  		name, player = data:match("^(%w*) (%d*)")
      print(name, player)
    end
	elseif msg_or_ip ~= 'timeout' then
		error("Unknown network error: "..tostring(msg))
	end

	socket.sleep(0.01)
end

print "Thank you."
