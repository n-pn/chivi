require "../../src/mt_ai/core/*"

time = Time.monotonic

text = ARGV[0]? || "(TOP (IP (PP (P 作为) (NP (QP (CD 一个)) (CP (CP (IP (VP (NP (NN 北国)) (VP (VV 长大)))) (DEC 的))) (NP (NR 维基亚)) (NP (NN 人)))) (PU ，) (NP (NR 奥利维尔)) (VP (ADVP (CS 虽然)) (ADVP (AD 不)) (VP (VV 厌恶) (NP (NP (NN 南方)) (DP (DT 那些)) (CP (CP (IP (VP (VP (VV 矫揉造作)) (VP (PP (P 随) (NP (NN 风))) (VP (VV 摆) (NP (NN 柳)))) (VP (VV 故作) (NP (NP (NR 扬州)) (NP (NN 瘦马)))))) (DEC 的))) (NP (NN 贵族) (NN 小姐))))) (PU ，) (ADVP (AD 但)) (NP (DNP (NP (DP (DT 这种)) (JJ 英姿飒爽) (NP (NN 性))) (DEG 的)) (NP (NN 美人))) (VP (ADVP (AD 或许)) (ADVP (AD 才)) (ADVP (AD 更)) (VP (VV 符合) (NP (DNP (NP (PN 他)) (DEG 的)) (NP (NN 品味))))) (PU 。)))"
dict = MT::AiDict.new(ARGV[1]? || "book/5865")

data = MT::AiData.parse_con_data(text)
data.root.tl_phrase!(dict: dict)

puts "--------------------------------".colorize.dark_gray
puts data.zstr.colorize.cyan
puts "--------------------------------".colorize.dark_gray
puts MT::QtCore.tl_hvword(data.zstr, true).colorize.light_gray
puts "--------------------------------".colorize.dark_gray
data.root.inspect(STDOUT)
puts
puts "--------------------------------".colorize.dark_gray
puts data.to_txt.colorize.yellow
puts "--------------------------------".colorize.dark_gray
puts data.to_cjo.colorize.cyan
puts "--------------------------------".colorize.dark_gray
puts "Total time used (including loading dicts): #{(Time.monotonic - time).total_milliseconds.round}ms".colorize.red
