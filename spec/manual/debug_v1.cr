require "../../src/mt_v1/core/m1_core"

text = ARGV[0]? || "苏简转头，今天的许陌陌穿着星黛露的ｃｏｓ服，看起来元气满满很是可爱。"
book = ARGV[1]?.try(&.to_i?) || 550200
user = ARGV[2]?

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
