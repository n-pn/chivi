require "../../src/mt_ai/core/*"

time = Time.monotonic

text = ARGV[0]? || "(TOP (IP (IP (NP (NR 宋青书)) (VP (VV 说) (IP (VP (VV 出去) (VP (VV 散散步)))))) (PU ，) (IP (NP (NR 周芷)) (VP (VP (ADVP (AD 若)) (ADVP (AD 毫不)) (VP (VV 在意))) (DEV 地) (VP (VV 点点头)))) (PU ，) (IP (NP (NR 宋青书)) (VP (VP (ADVP (ON 嘿嘿)) (VP (ADVP (CD 一)) (VP (VV 笑)))) (PU ，) (VP (VP (VV 走) (PP (P 在) (NP (NN 路上)))) (VP (VP (VP (ADVP (AD 一边)) (VP (VV 走))) (NP (NN 心中))) (VP (ADVP (AD 一边)) (VP (VV 骂) (PU ：) (IP (PU “) (NP (DP (DT 这个)) (NP (NN 女人))) (VP (VP (ADVP (AD 真)) (VP (VC 是) (VP (VA 无情)))) (PU ，) (VP (ADVP (AD 只)) (VP (VV 想) (AS 着) (NP (DNP (NP (PN 她)) (DEG 的)) (NP (NR 张无忌)))))) (PU …) (PU …)))))))) (PU ”) (IP (VP (IP (VP (IP (VP (VV 念念叨叨))) (ADVP (AD 很久)))) (PU ，) (VP (ADVP (AD 才)) (VP (VV 想起) (IP (NP (NT 现在)) (NP (PN 自己)) (VP (VP (VP (NP (QP (OD 第一)) (NP (VV 要) (NP (NN 务)))) (VP (VC 是) (IP (VP (VV 治好) (NP (DNP (NP (PN 自己)) (DEG 的)) (NP (NN 经脉))))))) (PU ，) (VP (ADVP (AD 然后)) (ADVP (AD 再)) (PP (P 在) (NP (DP (DT 这个)) (ADJP (JJ 超级)) (ADJP (JJ 大)) (NP (NN 乱世)))) (VP (VRD (VV 活) (VV 下去))))) (PU ，) (VP (ADVP (CC 而)) (ADVP (AD 不)) (VP (VC 是) (VP (VV 去) (VP (VV 吃) (NP (DNP (NP (NR 张无忌)) (DEG 的)) (NP (NN 飞醋))))))))))))) (PU 。)))"

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
