require "../../src/mt_ai/core/*"

time = Time.monotonic

text = ARGV[0]? || "(TOP (IP (IP (IP (IP (NP (NN 明眸)) (ADJP (VA 善)) (NP (NN 睐))) (PU ，) (IP (NP (NN 柳)) (VP (VA 娇)))) (IP (NP (NN 花)) (VP (VA 媚)))) (PU 。) (IP (IP (VP (PP (P 与) (NP (NP (DNP (NP (NN 左侧)) (DEG 的)) (NP (NN (NN 白衣) (NN 女郎)))))) (VP (VA 不同)))) (PU ，) (NP (PN 她)) (IP (IP 语笑嫣然) (PU ，) (IP (NP (NN 目光)) (VP (VA 促狭))))) (PU ，) (IP (VP (VP (VP (VV 配合) (AS 着)) (NP (NP (DNP (NP (NN 桃花) (ADJP (NN 红))) (DEG 的)) (NP (ADJP (JJ 鲜艳)) (NP (NN 衣裳)))))) (PU ，) (VP (VP (VP (PP (P 如同) (NP (NN 火焰))) (VP (VA 一般))) (PU ，) (VP (ADVP (AD 明明)) (VP (VA 危险)))) (PU ，) (VP (ADVP (AD 却)) (VP (VP (VV 令) (NP (NN 人)) (IP (VP (CP (CP (IP (VP (ADVP (AD 难以)) (VP (VV 自制)))) (DEV 的))) (VP (NP (NN 想要)) (IP (VP (VV 接近)))))))))))) (PU 。)))"

dict = ARGV[1]? || "up/1234"

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
puts data.to_json.colorize.cyan
puts "--------------------------------".colorize.dark_gray
puts "Total time used (including loading dicts): #{(Time.monotonic - time).total_milliseconds.round}ms".colorize.red

# puts dict.to_json
# puts MT::MtEpos::MAP
