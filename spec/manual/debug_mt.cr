require "../../src/cvmtl/engine"

text = ARGV[0]? || "第一章 屠龙之术"
book = ARGV[1]? || "combine"
user = ARGV[2]?
time = Time.monotonic

mtl = MT::Engine.new(book: book, user: user)
res = mtl.cv_plain(text)

res.inspect(STDOUT)
puts text.colorize.blue
puts "-----".colorize.dark_gray

puts res.to_txt.colorize.light_yellow
puts "-----".colorize.dark_gray

puts "Total time used (including loading dicts): #{(Time.monotonic - time).total_milliseconds.round}ms".colorize.red
