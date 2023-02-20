require "colorize"
require "../../src/mt_sp/sp_core"

text = ARGV[0]? || "然而这是他唯一的机会"
time = Time.monotonic

mtl = SP::MtCore.sino_vi
res = mtl.tokenize(text)

# res.inspect(STDOUT)
# puts "-----".colorize.dark_gray

puts text.colorize.blue
puts "-----".colorize.dark_gray

puts res.to_txt.colorize.light_yellow
puts "-----".colorize.dark_gray

puts "Total time used (including loading dicts): #{(Time.monotonic - time).total_milliseconds.round}ms".colorize.red
