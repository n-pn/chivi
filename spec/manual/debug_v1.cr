require "../../src/mt_v1/core/m1_core"

text = ARGV[0]? || "在魏梦柔的目光下"
book = ARGV[1]?.try(&.to_i) || 0
user = ARGV[2]?

time = Time.monotonic
mtl = M1::MtCore.generic_mtl(udic: book, user: user || "")
res = mtl.cv_plain(text)

res.inspect(STDOUT)
puts text.colorize.blue
puts "-----".colorize.dark_gray

puts res.to_txt.colorize.light_yellow
puts "-----".colorize.dark_gray

# puts TL::Engine.binh_am.convert(text).to_txt(cap: false).colorize.green
# puts "-----".colorize.dark_gray

puts "Total time used (including loading dicts): #{(Time.monotonic - time).total_milliseconds.round}ms".colorize.red
