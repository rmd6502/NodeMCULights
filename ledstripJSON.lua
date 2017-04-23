dofile("wificonfig.lua")
red1led=1   -- GPIO5
blue1led=6  -- GPIO12
green1led=7 -- GPIO13
red2led=2   -- GPIO4
blue2led=5  -- GPIO14
green2led=8 -- GPIO15

factor = 1023 / 255

m=mqtt.Client(config.clientName, 120)
t=tmr.create()

target =  { r=0,g=0,b=0 }
current = { r=0,g=0,b=0 }
inc =     { r=0,g=0,b=0 }

function handleLED(m, message)
    print("received "..message)
    m:publish("/log", "received message "..message, 0, 0)
    local status, result = pcall(cjson.decode,message)
    if not status then
      m:publish("/log", "failed to decode message"..message.." with error "..result, 0, 0)
      return
    end  
    local val=tonumber(string.sub(result.color, 2), 16)
    local brightness = result.brightness
    print("message decoded to "..val.." brightness "..brightness)
    if val == nil then return end
    target.b = math.floor((val % 256) * factor * brightness)
    inc.b = (current.b - target.b)
    val = math.floor(val / 256)
    target.g = math.floor((val % 256) * factor * brightness)
    inc.g = (current.g - target.g)
    val = math.floor(val / 256)
    target.r = math.floor(val * factor * brightness)
    inc.r = (current.r - target.r)
    steps=math.max(inc.r,inc.g,inc.b)
    if steps ~= 0 then
        inc.r = inc.r / steps
        inc.g = inc.g / steps
        inc.b = inc.b / steps
        t:start()
    end

    m:publish("/log", config.clientName.." set color to r"..target.r.."g"..target.g.."b"..target.b, 0, 0)
end

function updateLED()
    current.r = current.r + inc.r
    current.g = current.g + inc.g
    current.b = current.b + inc.b

    pwm.setduty(red1led, math.floor(current.r))
    pwm.setduty(green1led, math.floor(current.g))
    pwm.setduty(blue1led, math.floor(current.b))
    pwm.setduty(red2led, math.floor(current.r))
    pwm.setduty(green2led, math.floor(current.g))
    pwm.setduty(blue2led, math.floor(current.b))

    if target.r ~= current.r or target.g ~= current.g or target.b ~= current.b then
        t:start()
    end
end

function dispatch(client, topic, message)
  if message ~= nil and topic == config.subscribe then
    print("Dispatching "..topic.." "..message)
    handleLed(client, message)
  end
end

function updateLED()
end

m:on("connect", function(m)
  m:publish("/log","Connected", 0, 0)
  print("Connected")

  m:subscribe(config.subscribe, 0, function(m) m:publish("/log",
    config.clientName.." subscribed to LED updates "..config.subscribe,
    0, 0) end)
  print("subscribed to LED updates")
  t:start()
end)

t:register(100, tmr.ALARM_SEMI, updateLED)

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
