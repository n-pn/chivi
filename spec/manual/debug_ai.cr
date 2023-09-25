require "../../src/mt_ai/core/*"

time = Time.monotonic

text = ARGV[0]? || "(TOP (IP (IP (PU “) (INTJ (IJ 嗯)) (PU ，) (VP (ADVP (AD 确实)) (VP (VE 有) (NP (QP (CD 一些)) (NP (NN 问题))))) (PU ，) (IP (ADVP (AD 不过)) (VP (VV 放心))) (PU ，) (CP (IP (NP (PN 我)) (VP (VV 会) (VP (VRD (VV 处理) (VA 好))))) (SP 的)) (PU 。) (PU ”)) (IP (NP (NR 雅克)) (VP (VP (VV 笑) (AS 着)) (VP (VV 说道)))) (PU ，) (IP (LCP (NP (NN 言语)) (LC 之中)) (VP (ADVP (AD 满)) (VP (VC 是) (NP (NN 自信))))) (PU ，) (IP (NP (PN 他)) (VP (VP (ADVP (AD 缓步)) (VP (VV 来到) (NP (DNP (NP (NN 妻子)) (DEG 的)) (NP (NN 面前))))) (PU ，) (VP (ADVP (AD 慢慢)) (VP (VRD (VV 蹲) (VV 下来)))) (PU ，) (VP (DVP (VP (VA 小心翼翼)) (DEV 的)) (VP (VV 伏) (PP (P 在) (LCP (NP (NN 肚子)) (LC 上))))) (PU ，) (VP (VP (VV 笑) (AS 着)) (VP (VV 说道) (PU ：) (CP (PU “) (CP (IP (NP (NR 娜拉)) (PU ，) (NP (NN 爸爸)) (VP (VV 回来))) (SP 啦)) (PU ，) (CP (IP (VP (VNV (VE 有) (AD 没) (VE 有)) (VP (VV 想) (NP (NN 爸爸))))) (SP 啊))))))) (PU 。) (PU ”)))"

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
# puts MT::MtEpos::MAP
