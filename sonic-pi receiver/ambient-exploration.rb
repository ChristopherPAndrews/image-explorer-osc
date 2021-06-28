# Welcome to Sonic Pi

live_loop :osc do
  use_real_time
  
  x, y, r, lumi, highPass, lowPass, edge = sync "/osc*/image-metrics"
  synth :hollow, note: (lumi* 20) + 40
  synth :fm, note: ((lowPass - lumi) * 20) + 40
  
  
end


live_loop :osc2 do
  use_real_time
  
  x, y, r, lumi, highPass, lowPass, edge = sync "/osc*/image-metrics"
  if edge > 0
    sample :ambi_choir
    sleep sample_duration(:ambi_choir )
  end
  
end