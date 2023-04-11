require "colorize"
require "../../src/mtapp/qt_core"

time = Time.monotonic

DIC = MT::QtDict.new.load_dic!("base")
MTL = MT::QtCore.new(DIC)

text = ARGV[0]? || "“可以问你几个问题吗？”主持人开始线下活动互动了。"
# book = ARGV[1]?.try(&.to_i) || 5344
# user = ARGV[2]?

res = MTL.tokenize(text)
res.inspect(STDOUT)

puts
puts "-----".colorize.dark_gray

puts text.colorize.blue
puts "-----".colorize.dark_gray

puts res.to_txt.colorize.light_yellow
puts "-----".colorize.dark_gray

# puts TL::Engine.binh_am.convert(text).to_txt(cap: false).colorize.green
# puts "-----".colorize.dark_gray

puts "Total time used (including loading dicts): #{(Time.monotonic - time).total_milliseconds.round}ms".colorize.red

puts MT::FmtFlag.auto_detect "“"
