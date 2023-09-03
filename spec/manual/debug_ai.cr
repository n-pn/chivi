require "../../src/mt_ai/core/*"

time = Time.monotonic

text = ARGV[0]? || "(TOP (IP (PP (P 依靠) (NP (CP (CP (IP (NP (NR 克莱恩)) (VP (VV 残留))) (DEC 的))) (NP (NN 历史学) (NN 常识)))) (PU ，) (NP (PN 他)) (VP (VV 清楚) (IP (NP (CP (CP (IP (NP (PU “) (NP (ADJP (JJ 黑)) (NP (NN 铁))) (NP (NN 时代)) (PU ”)) (VP (VV 指))) (DEC 的)))) (VP (VP (VC 是) (NP (NP (NT 当前) (NN 纪元)) (PU ，) (PRN (VP (ADVP (AD 也就是)) (NP (NT 第五纪)))))) (PU ，) (IP (VP (VV 开始) (PP (P 于) (LCP (QP (CD 一千三百四十九) (CLP (M 年))) (LC 前)))))))) (PU 。)))"
dict = MT::AiDict.new(ARGV[1]? || "fixture")

data = MT::AiData.parse_con_data(text)
data.root.tl_phrase!(dict: dict)

puts "--------------------------------".colorize.dark_gray
puts data.zstr.colorize.cyan
puts "--------------------------------".colorize.dark_gray
puts MT::QtCore.tl_hvword(data.zstr, true).colorize.light_gray
puts "--------------------------------".colorize.dark_gray
pp data.root
puts "--------------------------------".colorize.dark_gray
puts data.to_txt.colorize.yellow

puts "--------------------------------".colorize.dark_gray
puts "Total time used (including loading dicts): #{(Time.monotonic - time).total_milliseconds.round}ms".colorize.red
