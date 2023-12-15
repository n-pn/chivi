require "colorize"
require "../../src/mt_ai/core/qt_core"

time = Time.monotonic

tests = {
  "坚定不移沿着中国123特色社会主义道路前进  为全面建成小康社会而奋斗",
  "MUV  LUV AL 红龙",
  "异闻录  每晚一个离奇的故事",
  "红龙M红~~~龙 MUV  LUV AL 红龙 http://sample.com/test?q=1故事",
  "https://sample.com/test?q=1故事",
  "左丰",
  "12：54",
  "一. 屠龙之术",
  "@ 无聊得很啊!!?",
  "为人作嫁",
  "兖､豫",
  "1+2+3  4",
  "修仙大佬她夺回气运后封神了",
}

tests.each do |test|
  test = CharUtil.to_canon(test, false)

  puts test.colorize.blue
  puts MT::QtCore.tl_hvname(test)

  res = MT::QtCore.hv_word.parse!(test)

  puts res.to_txt.colorize.light_yellow
  puts "-----".colorize.dark_gray
  # puts res.to_mtl.colorize.light_yellow
  # puts "-----".colorize.dark_gray


rescue ex
  puts ex.inspect_with_backtrace
end

puts "Total time used (including loading dicts): #{(Time.monotonic - time).total_milliseconds.round}ms".colorize.red
