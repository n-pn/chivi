require "../../src/cvmtl/engine"
require "../../src/cvhlp/engine"

text = ARGV[0]? || "在魏梦柔的目光下"
book = ARGV[1]? || "-qcwe8yg1"

time = Time.monotonic
mtl = MT::Engine.new(book: book)
res = mtl.cv_plain(text)

res.inspect(STDOUT)
puts text.colorize.blue
puts "-----".colorize.dark_gray

puts res.to_txt.colorize.light_yellow
puts "-----".colorize.dark_gray

puts TL::Engine.hanviet.convert(text).to_txt(cap: true).colorize.green
puts "-----".colorize.dark_gray

# puts TL::Engine.binh_am.convert(text).to_txt(cap: false).colorize.green
# puts "-----".colorize.dark_gray

puts "Total time used (including loading dicts): #{(Time.monotonic - time).total_milliseconds.round}ms".colorize.red
