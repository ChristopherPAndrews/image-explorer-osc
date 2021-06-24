# Welcome to Sonic Pi

live_loop :osc do
  use_real_time
  
  x, y, r, lumi, highPass, lowPass, edgeX, edgeY = sync "/osc*/image-metrics"
  synth :prophet, note: (edgeX * 20) + 40
  sleep 0.2
  ##| synth :prophet, note: (y * 20) + 60
end