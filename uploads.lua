fd=file.open("cat.lua","w+")
fd:writeline("  args={...}")
fd:writeline("  for idx = 1,#args do")
fd:writeline("    fd=file.open(args[idx])")
fd:writeline("    if fd ~= nil then")
fd:writeline("      while true do")
fd:writeline("        line=fd:read()")
fd:writeline("        if line == nil then")
fd:writeline("          break")
fd:writeline("        end")
fd:writeline("        print(line)")
fd:writeline("      end")
fd:writeline("      fd:close()")
fd:writeline("    end")
fd:writeline("  end")
fd:close()


fd=file.open("dir.lua","w+")
fd:writeline("for f,s in pairs(file.list()) do print (f..\": \"..s) end")
fd:writeline("remaining, used, total=file.fsinfo()")
fd:writeline("print(remaining..\" bytes free of \"..total)")
fd:close()


fd=file.open("init.lua","w+")
fd:writeline("function startup()")
fd:writeline("    if file.open(\"init.lua\") == nil then")
fd:writeline("        print(\"init.lua deleted or renamed\")")
fd:writeline("    else")
fd:writeline("        print(\"Running\")")
fd:writeline("        file.close(\"init.lua\")")
fd:writeline("        -- the actual application is stored in 'weatherstation.lua'")
fd:writeline("        dofile(\"telnet.lc\")")
fd:writeline("        print(\"telnet and mdns setup\")")
fd:writeline("        if config.initialFile ~= nil then")
fd:writeline("            dofile(config.initialFile)")
fd:writeline("        end")
fd:writeline("    end")
fd:writeline("end")
fd:writeline("")
fd:writeline("dofile(\"wificonfig.lua\")")
fd:writeline("wifi.setmode(wifi.STATION, true)")
fd:writeline("wifi.setphymode(wifi.PHYMODE_N)")
fd:writeline("wifi.sta.config(wifiConfig, true)")
fd:writeline("")
fd:writeline("wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function (ipInfo)")
fd:writeline("  print(\"\\nGot IP Address \"")
fd:writeline("    ..ipInfo.IP..")
fd:writeline("    \"\\n\")")
fd:writeline("  mdns.register(config.mdnsName,")
fd:writeline("    {hardware=\"Sparkfun\", dscription=\"Weather Station\"})")
fd:writeline("  print(\"Running in 3 seconds...\")")
fd:writeline("  tmr.create():alarm(3000, tmr.ALARM_SINGLE, startup)")
fd:writeline("end)")
fd:writeline("wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(discInfo)")
fd:writeline("  print(\"\\nDisconnected, reason id \"..discInfo.reason..\"\\n\")")
fd:writeline("end)")
fd:writeline("wifi.eventmon.register(wifi.eventmon.STA_DHCP_TIMEOUT, function()")
fd:writeline("  print(\"\\nDHCP Timeout, failed to connect\\n\")")
fd:writeline("end)")
fd:writeline("")
fd:writeline("cat=loadfile(\"cat.lua\")")
fd:writeline("dir=loadfile(\"dir.lua\")")
fd:writeline("")
fd:writeline("print(\"waiting for IP address...\")")
fd:close()


fd=file.open("ledstrip.lua","w+")
fd:writeline("dofile(\"wificonfig.lua\")")
fd:writeline("red1led=1")
fd:writeline("blue1led=6")
fd:writeline("green1led=7")
fd:writeline("red2led=1")
fd:writeline("blue2led=6")
fd:writeline("green2led=7")
fd:writeline("")
fd:writeline("factor = 1023 / 255")
fd:writeline("")
fd:writeline("m=mqtt.Client(config.clientName, 120)")
fd:writeline("")
fd:writeline("function handleLed(m, message)")
fd:writeline("    print(\"received \"..message)")
fd:writeline("    m:publish(\"/log\", \"received message \"..message, 0, 0)")
fd:writeline("    val=tonumber(string.sub(message, 2), 16)")
fd:writeline("    print(\"message decoded to \"..val)")
fd:writeline("    b = math.floor((val % 256) * factor)")
fd:writeline("    val = math.floor(val / 256)")
fd:writeline("    g = math.floor((val % 256) * factor)")
fd:writeline("    val = math.floor(val / 256)")
fd:writeline("    r = math.floor(val * factor)")
fd:writeline("")
fd:writeline("    print(config.clientName..\" set color to r\"..r..\"g\"..g..\"b\"..b)")
fd:writeline("    m:publish(\"/log\", config.clientName..\" set color to r\"..r..\"g\"..g..\"b\"..b, 0, 0)")
fd:writeline("    pwm.setduty(red1led, r)")
fd:writeline("    pwm.setduty(green1led, g)")
fd:writeline("    pwm.setduty(blue1led, b)")
fd:writeline("end")
fd:writeline("")
fd:writeline("function dispatch(client, topic, message)")
fd:writeline("  if message ~= nil and topic == config.subscribe then")
fd:writeline("    print(\"Dispatching \"..topic..\" \"..message)")
fd:writeline("    handleLed(client, message)")
fd:writeline("  end")
fd:writeline("end")
fd:writeline("")
fd:writeline("m:on(\"connect\", function(m)")
fd:writeline("  m:publish(\"/log\",\"Connected\", 0, 0)")
fd:writeline("  print(\"Connected\")")
fd:writeline("")
fd:writeline("  m:subscribe(config.subscribe, 0, function(m) m:publish(\"/log\",")
fd:writeline("    config.clientName..\" subscribed to LED updates \"..config.subscribe,")
fd:writeline("    0, 0) end)")
fd:writeline("  print(\"subscribed to LED updates\")")
fd:writeline("end)")
fd:writeline("")
fd:writeline("m:on(\"message\", dispatch)")
fd:writeline("")
fd:writeline("pwm.setup(red1led, 1000, 0)")
fd:writeline("pwm.start(red1led)")
fd:writeline("pwm.setup(green1led, 1000, 0)")
fd:writeline("pwm.start(green1led)")
fd:writeline("pwm.setup(blue1led, 1000, 0)")
fd:writeline("pwm.start(blue1led)")
fd:writeline("pwm.setup(red2led, 1000, 0)")
fd:writeline("pwm.start(red2led)")
fd:writeline("pwm.setup(green2led, 1000, 0)")
fd:writeline("pwm.start(green2led)")
fd:writeline("pwm.setup(blue2led, 1000, 0)")
fd:writeline("pwm.start(blue2led)")
fd:writeline("")
fd:writeline("m:connect(config.mqttBroker,1883,0,1)")
fd:writeline("print(\"Connecting\")")
fd:close()


fd=file.open("telnet.lua","w+")
fd:writeline("-- a simple telnet server")
fd:writeline("")
fd:writeline("telnet_srv = net.createServer(net.TCP, 180)")
fd:writeline("telnet_srv:listen(2323, function(socket)")
fd:writeline("    local fifo = {}")
fd:writeline("    local fifo_drained = true")
fd:writeline("")
fd:writeline("    local function sender(c)")
fd:writeline("        if #fifo > 0 then")
fd:writeline("            c:send(table.remove(fifo, 1))")
fd:writeline("        else")
fd:writeline("            fifo_drained = true")
fd:writeline("        end")
fd:writeline("    end")
fd:writeline("")
fd:writeline("    local function s_output(str)")
fd:writeline("        table.insert(fifo, str)")
fd:writeline("        if socket ~= nil and fifo_drained then")
fd:writeline("            fifo_drained = false")
fd:writeline("            sender(socket)")
fd:writeline("        end")
fd:writeline("    end")
fd:writeline("")
fd:writeline("    node.output(s_output, 0)   -- re-direct output to function s_ouput.")
fd:writeline("")
fd:writeline("    socket:on(\"receive\", function(c, l)")
fd:writeline("        node.input(l)           -- works like pcall(loadstring(l)) but support multiple separate line")
fd:writeline("    end)")
fd:writeline("    socket:on(\"disconnection\", function(c)")
fd:writeline("        node.output(nil)        -- un-regist the redirect output function, output goes to serial")
fd:writeline("    end)")
fd:writeline("    socket:on(\"sent\", sender)")
fd:writeline("")
fd:writeline("    print(\"Welcome to NodeMCU world.\")")
fd:writeline("end)")
fd:close()

