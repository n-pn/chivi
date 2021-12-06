require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("fnjqty5r")

inp = "周围是一个个谁比谁更无耻+无赖的同伙或敌人，身负国仇家恨，在一个风云突变的时代挣扎求存，巨大的压力下，要么爆发要么灭亡，遗憾的是主角变态了，于是仇人们倒霉了。"
res = GENERIC.cv_plain(inp)

[res.inspect, inp, res].each do |text|
  puts "--------", text
end
