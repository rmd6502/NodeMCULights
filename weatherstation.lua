dofile("wificonfig.lua")
m=mqtt.Client(config.clientName, 120)

function handleLed(m, message)
  if message == "on" then
    gpio.write(1, gpio.LOW)
    m:publish("/log",config.clientName.." LED on",0,0)
    print("led on")
  else
    gpio.write(1, gpio.HIGH)
    m:publish("/log",config.clientName.." LED off",0,0)
    print("led off")
  end
end

function dispatch(client, topic, message)
  if message ~= nil and topic == "/led" then
    handleLed(client, message)
  end
end

m:on("connect", function(m)
  m:publish("/log","Connected", 0, 0)
  print("Connected")

  m:subscribe("/led", 0, function(m) m:publish("/log",
    config.clientName.." subscribed to LED updates", 0, 0) end)
  print("subscribed to LED updates")
end)

m:on("message", dispatch)

m:connect(config.mqttBroker,1883,0,1)
gpio.mode(1,gpio.OUTPUT)
gpio.write(1,gpio.HIGH)
print("Connecting")
