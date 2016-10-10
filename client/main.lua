local socket = require "socket"

local address, port = "localhost", 7788 --NOTE type server here plz
local updaterate = 0.1
local t = 0

local list = {}

local x_offset = 80
local size = 20
local spacing = size + 10

function love.load()
  udp = socket.udp()
  udp:settimeout(0)
  udp:setpeername(address, port)
  math.randomseed(os.time())

  w, h = love.graphics.getDimensions()
  x_offset = x_offset / w
  size = size / h
  spacing = spacing / h

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
  w, h = love.graphics.getDimensions()
  dx_offset = x_offset * w
  dsize = size * h
  dspacing = spacing* h
  font = love.graphics.newFont("Lato-Light.ttf",  dsize)
  love.graphics.setFont(font)

  love.graphics.setColor(230, 69, 123)
  love.graphics.rectangle("fill", 0, 0, w, dspacing)
  love.graphics.setColor(0, 0, 0)
  love.graphics.print("Name", dx_offset, 0)
  love.graphics.print("Points", w/2+dx_offset, 0)

  for i=1, math.ceil(h/dspacing) do
    if i%2==0 then
      love.graphics.setColor(69, 123, 230)
    else
      love.graphics.setColor(80, 150, 250)
    end
    love.graphics.rectangle("fill", 0, i*dspacing, w, dspacing)
  end

  love.graphics.setColor(0, 0, 0)
  for i,v in pairs(list) do
    love.graphics.print(i, 10, i*dspacing)
    love.graphics.print(v.name, dx_offset, i*dspacing)
    love.graphics.print(v.points, w/2+dx_offset, i*dspacing)
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
