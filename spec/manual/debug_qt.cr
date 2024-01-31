require "colorize"
require "../../src/mt_ai/core/qt_core"

time = Time.monotonic

TEXT = ARGV[0]? || "“你不是来晚了，是看傻了吧。”她的语气从刚刚的悲愤已然转化成了明显的埋怨。但很快她就发现自己有些失态，很快就把那股埋怨藏了起来。"

QT_MT = MT::QtCore.new(MT::MtDict.for_mt("wn5344"))

puts "Dict loading time: #{(Time.monotonic - time).total_milliseconds.round}ms".colorize.red

res = QT_MT.tokenize(TEXT)
res.inspect(STDOUT)

puts
puts "-----".colorize.dark_gray

puts TEXT.colorize.blue
puts "-----".colorize.dark_gray

puts res.to_txt.colorize.light_yellow
puts "-----".colorize.dark_gray

# puts TL::Engine.binh_am.convert(text).to_txt(cap: false).colorize.green
# puts "-----".colorize.dark_gray

puts "Total time used (including loading dicts): #{(Time.monotonic - time).total_milliseconds.round}ms".colorize.red

puts MT::QtCore.verb_qt.tl_term("补完")
