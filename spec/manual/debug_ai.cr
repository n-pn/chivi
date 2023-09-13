require "../../src/mt_ai/core/*"

time = Time.monotonic

text = ARGV[0]? || "(NP (QP (QP (QP (OD 第)) (QP (CD １０７０) (CLP (M 章)))) (QP (OD 第三百九十七) (CLP (M 幕)))) (NP (NR 艾塔黎亚) (NN 矿物学)))"
dict = ARGV[1]? || "book/28832"

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
puts "--------------------------------".colorize.dark_gray
puts data.to_json.colorize.cyan
puts "--------------------------------".colorize.dark_gray
puts "Total time used (including loading dicts): #{(Time.monotonic - time).total_milliseconds.round}ms".colorize.red

# puts dict.to_json
# puts MT::MtCpos::MAP
