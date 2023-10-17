require "../../src/mt_v1/core/m1_core"

lines = <<-TXT
【单女主，狗粮文】
我女友可不止漂亮呢！
她…还……
打游戏时：
“你特么死不死啊！浪你妈啊！”
“E往无前是吧？！”
“艹尼玛，想投胎想疯了？？？”
学习时：
“四不四撒？数抄不对也算不对？不仅手残，脑袋也瘫了是吧？？”
“我寻思你也没算对啊……”
“……”
摸鱼时：
“我没记错的话，你昨天不是说要努力学习的吗？”
女友：“昨天是昨天，今天是今天。”
？？？
“今非昔比你懂吗？”
？？？
不懂。
还有，这个词是这么用的？？
聊天时：
“我喜欢你。”
“哦。”，冷漠.jpg
“好。”
女友：/////w/////？？？？
TXT

text = ARGV[0]? || "苏简转头，今天的许陌陌穿着星黛露的ｃｏｓ服，看起来元气满满很是可爱。"
book = ARGV[1]?.try(&.to_i?) || 139951
user = ARGV[2]?

lines.each_line do |text|
  puts text

  time = Time.monotonic
  mtl = M1::MtCore.init(udic: book, user: user || "")
  res = mtl.cv_plain(text)

  res.inspect(STDOUT)
  puts text.colorize.blue
  puts "-----".colorize.dark_gray

  puts res.to_txt.colorize.light_yellow
  puts "-----".colorize.dark_gray

  # puts TL::Engine.binh_am.convert(text).to_txt(cap: false).colorize.green
  # puts "-----".colorize.dark_gray

  puts "Total time used (including loading dicts): #{(Time.monotonic - time).total_milliseconds.round}ms".colorize.red
end
