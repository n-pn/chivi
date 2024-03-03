require "../../src/mt_ai/core/*"
require "../../src/mt_ai/data/*"

time = Time.monotonic

def debug(ztext : String, m_ver = 2_i8, dname = "combine")
  rcon = MT::MCache.find_con!([ztext], ver: m_ver).first

  data = MT::AiCore.load(dname).translate!(rcon)

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

ztext = ARGV[0]? || "“啊呀呀！”大大的伸了一个懒腰之后，尤里西斯的意识完全清醒了。"
m_ver = ARGV[1]?.try(&.to_i8?) || 3_i8
dname = ARGV[2]? || "wn33486"

MT::TextCut.split_sents(ztext) do |sent|
  puts [sent, m_ver, dname]
  debug(sent, m_ver, dname)
end

puts "--------------------------------".colorize.dark_gray
puts "Total time used (including loading dicts): #{(Time.monotonic - time).total_milliseconds.round}ms".colorize.red

# puts dict.to_json
# puts MT::MtEpos::MAP
