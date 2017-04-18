dofile("wificonfig.lua")

m=mqtt.Client(config.clientName, 120)
color = {0,0,0}
reda, redb, greena, greenb, bluea, blueb = 1,2,7,6,4,5
-- 5,4, 13,12, 2,14

if config.publish == nil then
  config.publish = config.subscribe
end

function handleLed(m, message)
    m:publish("/log", "received message "..message, 0, 0)
    val=tonumber(string.sub(message, 2), 16)
    b = math.floor(val % 256)
    val = math.floor(val / 256)
    g = math.floor(val % 256)
    val = math.floor(val / 256)
    r = math.floor(val)

    m:publish("/log", config.clientName.." set color to r"..r.."g"..g.."b"..b, 0, 0)
    color = {r, g, b}
end

function dispatch(client, topic, message)
  if message ~= nil and topic == config.subscribe then
    handleLed(client, message)
  end
end

function handlePos(chan, pos)
  color[chan] = math.min(255, math.max(0, math.floor(pos/4)))
  newcolor = string.format("#%02x%02x%02x", color[1], color[2], color[3])
  m:publish(config.publish, newcolor, 0,0)
  m:publish("/log", "setting "..newcolor, 0, 0)
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
print("rotary setup")

rotary.on(0, rotary.TURN, function (evt, pos, tstamp)
  pcall(handlePos, 1, pos)
end)
