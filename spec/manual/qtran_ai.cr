require "../../src/mt_ai/core/*"

input = [
  "“陈源哥哥，还记得高中时候的小瘸子吗？”",
]

ch_rm = 0
cinfo = [] of MT::M0Node | Nil

ch_rm.times do |index|
  title, split = MT::TlChap.split(input[index])
  input[index] = title
  cinfo << split
end

zdata = MT::MCache.find_con!(input, ver: 2_i8)
ai_mt = MT::AiCore.new("combine")

zdata.each_with_index do |line, l_id|
  vdata = ai_mt.translate!(line, pre: cinfo[l_id]?)

  puts "--------------------------------".colorize.dark_gray
  puts vdata.zstr.colorize.cyan
  puts "--------------------------------".colorize.dark_gray
  puts MT::QtCore.tl_hvword(vdata.zstr, true).colorize.light_gray
  puts "--------------------------------".colorize.dark_gray
  vdata.inspect(STDOUT)
  puts
  puts "--------------------------------".colorize.dark_gray
  puts vdata.to_txt.colorize.yellow
  # puts "--------------------------------".colorize.dark_gray
  puts vdata.to_json.colorize.cyan
  puts "--------------------------------".colorize.dark_gray
end
