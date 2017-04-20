-- Edit this file as appropriate
wifiConfig = {
    ssid="<your wifi BSSID here>",
    pwd="<your wifi PSK here>"
}
config = {
    clientName = "esp8266",
    mdnsName = "esp8266",
    mqttBroker = "test.mosquitto.org",
    initialFile = "ledstripJSON.lua",
    subscribe = "/livingroom/color"
}
