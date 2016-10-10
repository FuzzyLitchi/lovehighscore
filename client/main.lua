local socket = require "socket"

local address, port = "localhost", 7788
local updaterate = 0.1
local t = 0

local list = {}

local size = 20
local spacing = size + 10
local x_offset = 60
local y_offset = 30

function love.load()
  udp = socket.udp()
  udp:settimeout(0)
  udp:setpeername(address, port)
  math.randomseed(os.time())

  w, h = love.graphics.getDimensions()
  font = love.graphics.newFont("Lato-Light.ttf",  size)
  love.graphics.setFont(font)
end

function love.update(dt)
  t = t + dt

  if t > updaterate then t = 0; udp:send("update") end

  repeat
  	data, msg = udp:receive()

  	if data then
  			name, points = data:match("^(%w*) (%d*)")

        table.insert(list, {name=name, points=tonumber(points)})

  	elseif msg ~= 'timeout' then
  		error("Network error: "..tostring(msg))
  	end
  until not data

  table.sort(list, function(a,b) return a.points>b.points end)
end

function love.draw()
  love.graphics.setBackgroundColor(230, 69, 123)

  for i=1, math.ceil(h/spacing) do
    if i%2==0 then
      love.graphics.setColor(69, 123, 230)
    else
      love.graphics.setColor(80, 150, 250)
    end
    love.graphics.rectangle("fill", x_offset, y_offset+i*spacing, 400+x_offset, spacing)
  end

  love.graphics.setColor(0, 0, 0)
  for i,v in pairs(list) do
    love.graphics.print(v.name, x_offset, y_offset+i*spacing)
    love.graphics.print(v.points, 300+x_offset, y_offset+i*spacing)
  end
end

function love.keypressed(key, scancode, isrepeat)
  udp:send(string.format("JHN %d", math.random(0, 20)))
end
