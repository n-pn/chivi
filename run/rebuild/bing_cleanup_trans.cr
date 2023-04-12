require "colorize"
require "sqlite3"
require "./_shared"

DIC = DB.open("sqlite3:var/dicts/mtdic/base.dic")
at_exit { DIC.close }

names = DIC.query_all "select zstr from defns where xpos like '%NR%'", as: String
names = names.to_set

DIR = "var/dicts/outer"

cached = Hash(String, Array(String)).new { |h, k| h[k] = Array(String).new }

File.each_line("#{DIR}/btrans.tsv") do |line|
  next if line.empty?

  zstr, vstr = line.split('\t')
  vstr = vstr.sub(/^[\s*,]+/, "")

  cached[zstr] << vstr unless vstr.empty?
end

puts "cached: #{cached.size}"

count = 0

out_path = "#{DIR}/../_temp/bing-cleaned.tsv"
File.open(out_path, "w") do |file|
  cached.each do |zstr, vals|
    next if vals.empty?

    vstr = vals.find(vals.first) { |x| is_lower?(x) }

    if is_lower?(vstr) || vstr != vstr.capitalize
      # ok
    elsif names.includes?(zstr)
      vstr = vals.join('\t')
      # puts "#{zstr} => #{vstr}".colorize.green
    else
      vals.map!(&.downcase) # if vstr.includes?(' ')
      vstr = vals.join('\t')
      # puts "#{zstr} => #{vstr}".colorize.red
    end

    file << zstr << '\t' << vstr << '\n'
    count += 1
  end
end

puts "output: #{count}"
