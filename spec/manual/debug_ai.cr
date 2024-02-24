require "../../src/mt_ai/core/*"
require "../../src/mt_ai/data/*"

time = Time.monotonic

def debug(text : String, dict = "combine", malg = 2_i8)
  rcon = MT::MCache.find_con!([text], ver: malg).first

  data = MT::AiCore.load(dict).translate!(rcon)

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

text = ARGV[0]? || "“啊呀呀！”大大的伸了一个懒腰之后，尤里西斯的意识完全清醒了。"
malg = ARGV[1]?.try(&.to_i8?) || 3_i8
dict = ARGV[2]? || "up1234"

bases, texts, l_ids = MT::TextCut.split_ztext(text)

texts.each do |sent|
  print sent
  debug(sent, dict)
end

puts "--------------------------------".colorize.dark_gray
puts "Total time used (including loading dicts): #{(Time.monotonic - time).total_milliseconds.round}ms".colorize.red

# puts dict.to_json
# puts MT::MtEpos::MAP
