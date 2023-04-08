require "colorize"
require "../../src/mtapp/ner_core"

time = Time.monotonic

tests = {
  # "坚定不移沿着中国特色社会主义道路前进  为全面建成小康社会而奋斗",
  "MUV  LUV-AL 红龙",
  # "异闻录  每晚一个离奇的故事",
  "红龙M红~~~龙 MUV  LUV AL 红龙 http://test.com/test?q=12 56 444",
  " https://test.com/test?q=12",
  "wwwtest",
  "www.test.com/test?q=12",
  # "左丰",
  "12",
  # "一. 屠龙之术",
  "@ 无聊得很啊",
  # "为人作嫁",
}

tests.each do |test|
  puts test.colorize.cyan.bold

  MT::NerCore.translit.fetch_all(test.chars) do |idx, len, mark, value|
    puts [idx, len, mark.to_s, value].colorize.yellow
  end
rescue ex
  puts ex.inspect_with_backtrace
end

puts "Total time used (including loading dicts): #{(Time.monotonic - time).total_milliseconds.round}ms".colorize.red
