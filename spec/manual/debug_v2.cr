require "../../src/mt_v2/m2_core"
require "../../src/mt_sp/sp_core"

text = ARGV[0]? || "泽林有些意外的看着这位吸血鬼。"
book = ARGV[1]? || "-ty24ejjk"

time = Time.monotonic
mtl = M2::Engine.new(book: book)
res = mtl.cv_plain(text)

res.inspect(STDOUT)
puts text.colorize.blue
puts "-----".colorize.dark_gray

puts res.to_txt.colorize.light_yellow
puts "-----".colorize.dark_gray

puts SP::Engine.hanviet.convert(text).to_txt(cap: true).colorize.green
puts "-----".colorize.dark_gray

# puts TL::Engine.binh_am.convert(text).to_txt(cap: false).colorize.green
# puts "-----".colorize.dark_gray

puts "Total time used (including loading dicts): #{(Time.monotonic - time).total_milliseconds.round}ms".colorize.red
