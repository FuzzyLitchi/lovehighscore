local socket = require "socket"

local udp = socket.udp()

udp:settimeout(0)
udp:setsockname('*', 7788)

local update
local data, msg_or_ip, port_or_nil
local all = {}
local users = {}
local running = true

print "Beginning server loop."

while running do
	data, msg_or_ip, port_or_nil = udp:receivefrom()

	if data then
    if data=="update" then
			--check person
			local new_user = true

			for i, v in pairs(users) do
				if i == msg_or_ip then new_user = false; break end -- not new person
			end

			if new_user then --if new person
				print("new dude detected dude")

				for i, v in pairs(all) do
					udp:sendto(v, msg_or_ip, port_or_nil)											--send all the fucking data
				end
				users[msg_or_ip] = {}							--set them up fam
			else																--if not new
				for i, v in pairs(users[msg_or_ip]) do --here is your updates sir
					udp:sendto(v, msg_or_ip, port_or_nil)
				end
				users[msg_or_ip] = {}
			end
    else																--or if this is just data for me to record then rec
			table.insert(all, data)
			for i, v in pairs(users) do
				table.insert(v,data)
			end

--  		name, player = data:match("^(%w*) (%d*)")
      print(data)
    end
	elseif msg_or_ip ~= 'timeout' then
		error("Unknown network error: "..tostring(msg))
	end

	socket.sleep(0.01)
end

print "Thank you."
