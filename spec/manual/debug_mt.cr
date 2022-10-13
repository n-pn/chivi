require "../../src/cvmtl/engine"

input = ARGV[0]? || "在残留的星火之能的牵引"
dname = ARGV[1]? || "-mvttgmnj"
uname = ARGV[2]?

time = Time.monotonic

mtl = MT::Engine.new(dname, uname)
res = mtl.cv_plain(input)

res.inspect(STDOUT)
puts input.colorize.blue
puts "-----".colorize.dark_gray

puts res.to_txt.colorize.light_yellow
puts "-----".colorize.dark_gray

puts "Total time used (including loading dicts): #{(Time.monotonic - time).total_milliseconds.round}ms".colorize.red
