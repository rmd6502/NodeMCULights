function startup()
    if file.open("init.lua") == nil then
        print("init.lua deleted or renamed")
    else
        print("Running")
        file.close("init.lua")
        -- the actual application is stored in 'weatherstation.lua'
        dofile("telnet.lc")
        print("telnet and mdns setup")
        if config.initialFile ~= nil then
            dofile(config.initialFile)
        end
    end
end

dofile("wificonfig.lua")
wifi.setmode(wifi.STATION, true)
wifi.setphymode(wifi.PHYMODE_N)
wifi.sta.config(wifiConfig, true)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function (ipInfo)
  print("\nGot IP Address "
    ..ipInfo.IP..
    "\n")
  mdns.register(config.mdnsName,
    {hardware="Sparkfun", dscription="Weather Station"})
  print("Running in 3 seconds...")
  tmr.create():alarm(3000, tmr.ALARM_SINGLE, startup)
end)
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(discInfo)
  print("\nDisconnected, reason id "..discInfo.reason.."\n")
end)
wifi.eventmon.register(wifi.eventmon.STA_DHCP_TIMEOUT, function()
  print("\nDHCP Timeout, failed to connect\n")
end)

cat=loadfile("cat.lua")
dir=loadfile("dir.lua")

print("waiting for IP address...")
