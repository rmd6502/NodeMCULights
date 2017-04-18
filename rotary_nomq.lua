
color = {0,0,0}
pins = { 1,2,7,6,4,5 }
-- 5,4, 13,12, 2,14

function handlePos(chan, pos)
  print("channel "..chan.." pos "..pos)
  color[chan] = math.min(255, math.max(0, math.floor(pos/4)))
  newcolor = string.format("#%02x%02x%02x", color[1], color[2], color[3])
  print("setting "..newcolor)
end

for chan=0,2 do
  rotary.setup(chan, pins[chan * 2 + 1], pins[chan * 2 + 2])
  rotary.on(chan, rotary.TURN, function (evt, pos, tstamp)
    pcall(handlePos, chan+1, pos)
  end)
end
