require "sqlite3"
require "colorize"
require "../../../src/mt_sp/util/ms_tran"

DIR = "var/dicts/outer"

cached = Hash(String, Set(String)).new { |h, k| h[k] = Set(String).new }

out_path = "#{DIR}/btrans.tsv"

File.each_line(out_path) do |line|
  next if line.empty?
  zstr, vstr = line.split('\t', 2)
  cached[zstr] << vstr
end

puts "cached: #{cached.size}"

DIC = DB.open("sqlite3:var/dicts/mtdic/base.dic")
at_exit { DIC.close }

inputs = DIC.query_all "select zstr from defns where vstr = '' and _flag < 4", as: String
# inputs.select! { |x| x.matches?(/\p{Han}/) }
# inputs.select! { |x| !cached.has_key?(x) }

inputs.shuffle!

inputs.each_slice(100) do |group|
  puts group.join("  ")

  SP::MsTran.translate(group, no_cap: true).each do |(zh, vi)|
    next unless cached[zh].add?(vi)
    File.open(out_path, "a", &.puts("#{zh}\t#{vi}"))
    puts "#{zh} => #{vi}".colorize.green
  end
end

puts "total: #{cached.size}"
