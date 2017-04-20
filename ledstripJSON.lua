dofile("wificonfig.lua")
red1led=1   -- GPIO5
blue1led=6  -- GPIO12
green1led=7 -- GPIO13
red2led=2   -- GPIO4
blue2led=5  -- GPIO14
green2led=8 -- GPIO15

factor = 1023 / 255

m=mqtt.Client(config.clientName, 120)

function handleLed(m, message)
    print("received "..message)
    m:publish("/log", "received message "..message, 0, 0)
    local status, result = pcall(cjson.decode,message)
    if not status then
      m:publish("/log", "failed to decode message message "..result, 0, 0)
      return
    end  
    local val=tonumber(string.sub(result.color, 2), 16)
    local brightness = result.brightness
    print("message decoded to "..val.." brightness "..brightness)
    if val == nil then return end
    b = math.floor((val % 256) * factor * brightness)
    val = math.floor(val / 256)
    g = math.floor((val % 256) * factor * brightness)
    val = math.floor(val / 256)
    r = math.floor(val * factor * brightness)

    print(config.clientName.." set color to r"..r.."g"..g.."b"..b)
    m:publish("/log", config.clientName.." set color to r"..r.."g"..g.."b"..b, 0, 0)
    pwm.setduty(red1led, r)
    pwm.setduty(green1led, g)
    pwm.setduty(blue1led, b)
    pwm.setduty(red2led, r)
    pwm.setduty(green2led, g)
    pwm.setduty(blue2led, b)
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
