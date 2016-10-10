local socket = require "socket"

local address, port = "localhost", 7788 --NOTE type server here plz
local updaterate = 0.1
local t = 0

local list = {}

local size = 20
local spacing = size + 10
local x_offset = 80

function love.load()
  udp = socket.udp()
  udp:settimeout(0)
  udp:setpeername(address, port)
  math.randomseed(os.time())

  w, h = love.graphics.getDimensions()
  font = love.graphics.newFont("Lato-Light.ttf",  size)
  love.graphics.setFont(font)

  --get info
  udp:send("start")
  receive_udp()
end

function love.update(dt)
  t = t + dt

  if t > updaterate then t = 0; udp:send("update") end

  receive_udp()

  table.sort(list, function(a,b) return a.points>b.points end)
end

function love.draw()
  love.graphics.setColor(230, 69, 123)
  love.graphics.rectangle("fill", 0, 0, w, spacing)
  love.graphics.setColor(0, 0, 0)
  love.graphics.print("Name", x_offset, 0)
  love.graphics.print("Points", w/2+x_offset, 0)

  for i=1, math.ceil(h/spacing) do
    if i%2==0 then
      love.graphics.setColor(69, 123, 230)
    else
      love.graphics.setColor(80, 150, 250)
    end
    love.graphics.rectangle("fill", 0, i*spacing, w, spacing)
  end

  love.graphics.setColor(0, 0, 0)
  for i,v in pairs(list) do
    love.graphics.print(v.name, x_offset, i*spacing)
    love.graphics.print(v.points, w/2+x_offset, i*spacing)
  end
end

function love.keypressed(key, scancode, isrepeat)
  udp:send(string.format("JHN %d", math.random(0, 20)))
end

function receive_udp ()
  repeat
  	data, msg = udp:receive()

  	if data then
  			name, points = data:match("^(%w*) (%d*)")

        table.insert(list, {name=name, points=tonumber(points)})

  	elseif msg ~= 'timeout' then
  		error("Network error: "..tostring(msg))
  	end
  until not data
end
