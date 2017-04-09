dofile("wificonfig.lua")

m=mqtt.Client(config.clientName, 120)
color = {0,0,0}
lastpos = {0,0,0}
reda, redb, greena, greenb, bluea, blueb = 5,4,13,12,16,14

if config.publish == nil then
  config.publish = config.subscribe
end

function handleLed(m, message)
    print("received "..message)
    m:publish("/log", "received message "..message, 0, 0)
    val=tonumber(string.sub(message, 2), 16)
    print("message decoded to "..val)
    b = math.floor(val % 256)
    val = math.floor(val / 256)
    g = math.floor(val % 256)
    val = math.floor(val / 256)
    r = math.floor(val)

    print(config.clientName.." set color to r"..r.."g"..g.."b"..b)
    m:publish("/log", config.clientName.." set color to r"..r.."g"..g.."b"..b, 0, 0)
    color = {r, g, b}
end

function dispatch(client, topic, message)
  if message ~= nil and topic == config.subscribe then
    print("Dispatching "..topic.." "..message)
    handleLed(client, message)
  end
end

function handlePos(chan, pos)
  color[chan] = math.floor((pos - lastpos[chan])/4)
  lastpos[chan] = pos
  newcolor = string.format("#%02x%02x%02x", color[0], color[1], color[2])
  m:publish(config.publish, newcolor, 0,0)
  m:publish("/log", "setting "..newcolor, 0, 0)
  print("setting "..newcolor)
end

m:on("connect", function(m)
  m:publish("/log","Connected", 0, 0)
  print("Connected")

  m:subscribe(config.subscribe, 0, function(m) m:publish("/log",
    config.clientName.." subscribed to LED updates "..config.subscribe,
    0, 0) end)
  print("subscribed to LED updates")
end)

m:on("message", dispatch)

m:connect(config.mqttBroker,1883,0,1)
print("Connecting")

rotary.setup(0, reda, redb)
rotary.setup(1, greena, greenb)
rotary.setup(2, bluea, blueb)

for chan = 0, 3 do
  rotary.on(chan, rotary.TURN, function (evt, pos, tstamp)
    handlePos(chan, pos)
  end)
end
