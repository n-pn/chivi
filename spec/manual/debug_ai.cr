require "../../src/mt_ai/core/*"

time = Time.monotonic

def debug(text : String, dict = "combine")
  text = text.gsub(/\n\s+/, " ")
  data = MT::AiCore.load(dict).translate!(MT::RawCon.from_text(text))

  puts "--------------------------------".colorize.dark_gray
  puts data.zstr.colorize.cyan
  puts "--------------------------------".colorize.dark_gray
  puts MT::QtCore.tl_hvword(data.zstr, true).colorize.light_gray
  puts "--------------------------------".colorize.dark_gray
  data.inspect(STDOUT)
  puts
  puts "--------------------------------".colorize.dark_gray
  puts data.to_txt.colorize.yellow
  # puts "--------------------------------".colorize.dark_gray
  # puts data.to_json.colorize.cyan
end

text = ARGV[0]? || "(TOP (CP (PU “) (NP (NR 陈源) (NN 哥哥)) (PU ，) (VP (ADVP (AD 还)) (VP (VV 记得) (NP (DNP (NP (NN 高中) (NN 时候)) (DEG 的)) (ADJP (JJ 小)) (NP (NN 瘸子))))) (SP 吗) (PU ？) (PU ”)))"
dict = ARGV[1]? || "up1234"

debug(text, dict)
puts "--------------------------------".colorize.dark_gray
puts "Total time used (including loading dicts): #{(Time.monotonic - time).total_milliseconds.round}ms".colorize.red

# puts dict.to_json
# puts MT::MtEpos::MAP
