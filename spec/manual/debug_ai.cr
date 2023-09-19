require "../../src/mt_ai/core/*"

time = Time.monotonic

text = ARGV[0]? || "(TOP (UCP (IP (PP (P 在) (LCP (NP (NN 生活习惯)) (LC 上))) (PU ，) (NP (NP (PN 我)) (CC 和) (NP (NR 荆君))) (VP (VE 有) (NP (NP (CP (CP (IP (VP (ADVP (AD 很)) (VP (VA 大)))) (DEC 的))) (NP (NN 不同))))) (PU 。) (IP (NP (PN 我)) (VP (ADVP (AD 总是)) (VP (VV 喜欢) (NP (NP (CP (CP (IP (VP (VCD (VA 简朴) (VA 素净)))) (DEC 的))) (NP (NN 装饰) (CC 和) (NN 家具)))))))) (PU ，) (IP (ADVP (CC 但)) (NP (NR 荆君)) (VP (ADVP (AD 却)) (VP (VV 喜欢) (NP (NP (NP (CP (CP (IP (VP (VA 艳丽))) (DEC 的))) (NP (NN 色彩)))) (CC 和) (NP (NP (CP (CP (IP (VP (VA 精致))) (DEC 的))) (NP (NN 器具)))))))) (PU ，) (IP (ADVP (CC 而且)) (NP (PN 他)) (VP (VV 偏爱) (PP (P 于) (IP (NP (PN 我)) (VP (VV 觉得) (NP (NP (CP (CP (IP (VP 冷冰冰)) (DEC 的))) (NP (NN 人造物))))))))) (PU 。) (IP (PP (PP (P 用) (NP (NP (DNP (NP (PN 他)) (DEG 的)) (NP (NN 话))))) (LC 来说)) (PU ，) (NP (NP (DP (DT 这些)) (NP (NN 工业产品)))) (VP (PU “) (VV 见证) (AS 了) (NP (NP (DNP (NP (NN 文明) (CC 与) (NN 生产力)) (DEG 的)) (NP (NN 进步)))) (PU ”))) (PU ，) (CP (IP (NP (IP (NP (PN 他)) (VP (VV 可以) (VP (PP (P 从) (LCP (NP (NP (DP (DT 这些)) (NP (NN 造物)))) (LC 中))) (VP (VRD (VV 体会) (VV 到)) (NP (NP (DNP (NP (NN (NN 设计者) (NP (NN 们)))) (DEG 的)) (NP (NN 心血)))))))) (PU ……) (ADVP (AD 或许)) (NP (PN 这))) (VP (VC 是) (NP (NP (DNP (NP (NP 身) (VP (VC 为) (NP (NN (NN 科学) (NN 研究者))))) (DEG 的)) (NP (NN 天性)))))) (SP 吧)) (PU 。)))"

dict = ARGV[1]? || "book/7154"

data = MT::AiCore.new(dict).tl_from_con_data(text)

puts "--------------------------------".colorize.dark_gray
puts data.zstr.colorize.cyan
puts "--------------------------------".colorize.dark_gray
puts MT::QtCore.tl_hvword(data.zstr, true).colorize.light_gray
puts "--------------------------------".colorize.dark_gray
data.root.inspect(STDOUT)
puts
puts "--------------------------------".colorize.dark_gray
puts data.to_txt.colorize.yellow
# puts "--------------------------------".colorize.dark_gray
# puts data.to_json.colorize.cyan
puts "--------------------------------".colorize.dark_gray
puts "Total time used (including loading dicts): #{(Time.monotonic - time).total_milliseconds.round}ms".colorize.red

# puts dict.to_json
# puts MT::MtCpos::MAP
