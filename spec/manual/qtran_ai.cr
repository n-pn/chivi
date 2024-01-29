require "../../src/mt_ai/core/*"
require "../../src/mt_ai/data/*"

input = [
  "第２７３８章京师（九十一）",
  # "“陈源哥哥，还记得高中时候的小瘸子吗？”",
  # "“钱芊雪除外。”",
  # "渡边澈两个手掌那么大、放在铁板上滋滋作响的鱿鱼，整个卖１５００円；",
  # "她们都能听到我的心声",
  # "“你不是来晚了，是看傻了吧。”她的语气从刚刚的悲愤已然转化成了明显的埋怨。但很快她就发现自己有些失态，很快就把那股埋怨藏了起来。",
  # "我会好好学习",
  # "就像三木清说的那样，孤独不是在山上而是在街上，不在一个人里面而在许多人中间。",
  # "说不定我们并没有血缘关系什么的,我一边妄想着像是黄游一样的方便展开,一边委身于往复运动的右手.",
  # "顿了顿后石一开口道：“我答应他，高考拿下省状元。”",
  "这句话一出空气瞬间凝结。",
  "“所以他，特恩布尔他才会在死前说那样一番话。”",
  "那些特恩布尔靠着坑蒙拐骗和威逼利诱，靠着宰掉前一批老大而积攒起来，对他拍胸脯表忠心的狂热狗腿子们。",
]

ch_rm = 1
cheads = [] of MT::MtNode | Nil

ch_rm.times do |index|
  title, split = MT::TlChap.split(input[index])
  input[index] = title
  cheads << split
end

zdata = MT::MCache.find_con!(input, ver: 3_i8)
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
