require "colorize"
require "../../src/mtapp/qt_core"

time = Time.monotonic

TEXT = ARGV[0]? || "他也懒得计较，大大方方地点了点头，反正他也不是什么知名人物，就算露个脸也没什么关系。"
D_ID = ARGV[1]?.try(&.to_i) || 5344
USER = ARGV[2]? || ""

QT_MT = MT::QtCore.new(D_ID, USER)

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

puts MT::FmtFlag.auto_detect "“"
