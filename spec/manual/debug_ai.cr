require "../../src/mt_ai/core/*"

time = Time.monotonic

text = ARGV[0]? || "(TOP (IP (IP (NP (NR 芙兰)) (VP (VV 希望) (IP (NP (NR 卡兹)) (VP (VP (VV 能够) (VP (VV 理解) (NP (PN 自己)))) (PU ，) (VP (ADVP (AD 然后)) (PP (P 与) (NP (PN 自己))) (VP (VV 站) (PP (P 在) (ADVP (AD 一起)))) (VP (VV 反抗) (NP (DNP (NP (NN 姐姐)) (DEG 的)) (ADJP (ADVP (AD 不)) (ADJP (JJ 公平))) (NP (NN 行为))))))))) (PU ，) (IP (NP (PN 她)) (VP (VV 相信) (CP (IP (CP (ADVP (CS 只要)) (IP (VP (VE 有) (NP (DNP (NP (NR 卡兹)) (DEG 的)) (NP (NN 加入)))))) (ADVP (AD 那么)) (VP (ADVP (AD 就)) (ADVP (AD 一定)) (VP (VV 会) (VP (VV 让) (NP (DP (DT 这) (CLP (M 场))) (NP (NN 反抗) (NN 行动))) (IP (VP (VV 取得) (NP (NN 胜利)))))))) (SP 的)))) (PU 。)))"
dict = ARGV[1]? || "book/122042"

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
