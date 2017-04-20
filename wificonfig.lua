-- Edit this file as appropriate
wifiConfig = {
    ssid="<your wifi BSSID here>",
    pwd="<your wifi PSK here>"
}
config = {
    clientName = "esp8266",
    mdnsName = "esp8266",
    mqttBroker = "10.0.0.77",
    initialFile = "ledstripJSON.lua",
    subscribe = "/kitchen/led"
}
