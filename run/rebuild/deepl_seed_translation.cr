require "sqlite3"
require "colorize"

require "../../src/mtapp/service/deepl_api"

DIR = "var/dicts/outer"

cached = Hash(String, Set(String)).new { |h, k| h[k] = Set(String).new }

out_path = "#{DIR}/deepls.tsv"

File.each_line(out_path) do |line|
  next if line.empty?
  zstr, vstr = line.split('\t', 2)
  cached[zstr] << vstr
end

puts "cached: #{cached.size}"

DIC = DB.open("sqlite3:var/dicts/mtdic/base.dic")
at_exit { DIC.close }

inputs = DIC.query_all "select zstr from defns where xpos like '%NR%'", as: String
inputs.select! { |x| x.matches?(/\p{Han}/) }

inputs.shuffle!

inputs.each_slice(100) do |group|
  puts group.join("  ")

  SP::Deepl.translate(group, target: "en").each do |(zstr, vstr)|
    next unless cached[zstr].add?(vstr)
    File.open(out_path, "a", &.puts("#{zstr}\t#{vstr}"))
    puts "#{zstr} => #{vstr}".colorize.green
  end
end

puts "total: #{cached.size}"
