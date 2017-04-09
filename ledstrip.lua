dofile("wificonfig.lua")
red1led=1
blue1led=6
green1led=7
red2led=1
blue2led=6
green2led=7

factor = 1023 / 255

m=mqtt.Client(config.clientName, 120)

function handleLed(m, message)
    print("received "..message)
    m:publish("/log", "received message "..message, 0, 0)
    val=tonumber(string.sub(message, 2), 16)
    print("message decoded to "..val)
    b = math.floor((val % 256) * factor)
    val = math.floor(val / 256)
    g = math.floor((val % 256) * factor)
    val = math.floor(val / 256)
    r = math.floor(val * factor)

    print(config.clientName.." set color to r"..r.."g"..g.."b"..b)
    m:publish("/log", config.clientName.." set color to r"..r.."g"..g.."b"..b, 0, 0)
    pwm.setduty(red1led, r)
    pwm.setduty(green1led, g)
    pwm.setduty(blue1led, b)
end

function dispatch(client, topic, message)
  if message ~= nil and topic == config.subscribe then
    print("Dispatching "..topic.." "..message)
    handleLed(client, message)
  end
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

pwm.setup(red1led, 1000, 0)
pwm.start(red1led)
pwm.setup(green1led, 1000, 0)
pwm.start(green1led)
pwm.setup(blue1led, 1000, 0)
pwm.start(blue1led)
pwm.setup(red2led, 1000, 0)
pwm.start(red2led)
pwm.setup(green2led, 1000, 0)
pwm.start(green2led)
pwm.setup(blue2led, 1000, 0)
pwm.start(blue2led)

m:connect(config.mqttBroker,1883,0,1)
print("Connecting")
