require "../../src/mt_ai/core/*"

time = Time.monotonic

text = ARGV[0]? || "(TOP (IP (NP (PU “) (NP (DNP (NP (NN 水泥地)) (DEG 的)) (NP (NN 缘故))) (PU ？) (PU ”)) (IP (NP (NR 高栋)) (VP (VP (VV 当) (AS 了) (NP (QP (ADVP (AD 这么)) (QP (CD 多) (CLP (M 年)))) (NP (NN 刑警)))) (PU ，) (VP (ADVP (AD 自然)) (VP (VV 知道) (NP (NN 常识)))))) (PU ，) (IP (IP (IP (NP (NN 脚印)) (VP (PP (P 在) (NP (CP (CP (IP (VP (VA 干净))) (DEC 的))) (NP (NN 水泥地上)))) (ADVP (AD 很)) (ADVP (AD 难)) (VP (VRD (VV 保留) (VA 完整))))) (PU ，) (ADVP (CC 但)) (NP (PN 他)) (VP (VV 看) (NP (DNP (NP (PN 这里)) (DEG 的)) (NP (NN 路面))))) (PU ，) (IP (PP (P 由于) (IP (NP (NN 旁边)) (VP (VC 是) (NP (ADJP (JJ 荒)) (NP (NN 田)))))) (PU ，) (IP (NP (NN 路边)) (VP (VE 有) (NP (CP (CP (IP (VP (ADVP (AD 挺)) (VP (VA 多)))) (DEC 的))) (NP (NN 泥沙))))))) (PU ，) (IP (ADVP (AD 照理)) (NP (NN 脚印)) (VP (ADVP (AD 也)) (VP (VV 该) (VP (VV 能) (VP (VV 留下来)))))) (PU 。)))
"

dict = ARGV[1]? || "book/54963"

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
# puts MT::MtEpos::MAP
