require "../../src/mt_ai/core/*"

input = [
  # "“陈源哥哥，还记得高中时候的小瘸子吗？”",
  # "“钱芊雪除外。”",
  "第２７３８章京师（九十一）",
  "渡边澈两个手掌那么大、放在铁板上滋滋作响的鱿鱼，整个卖１５００円；",
]

ch_rm = 1
cheads = [] of MT::AiTerm | Nil

ch_rm.times do |index|
  title, split = MT::TlChap.split(input[index])
  input[index] = title
  cheads << split
end

zdata = MT::MCache.find_con!(input, ver: 2_i8)
ai_mt = MT::AiCore.new("wn48576")

zdata.each_with_index do |rcon, l_id|
  data = ai_mt.translate!(rcon, prfx: cheads[l_id]?)

  puts "--------------------------------".colorize.dark_gray
  puts data.zstr.colorize.cyan
  puts "--------------------------------".colorize.dark_gray
  puts MT::QtCore.tl_hvword(data.zstr, true).colorize.light_gray
  puts "--------------------------------".colorize.dark_gray
  puts rcon
  puts "--------------------------------".colorize.dark_gray
  data.inspect(STDOUT)
  puts
  puts "--------------------------------".colorize.dark_gray
  puts data.to_txt.colorize.yellow
  # puts "--------------------------------".colorize.dark_gray
  # puts data.to_json.colorize.cyan
  puts "--------------------------------".colorize.dark_gray
end
