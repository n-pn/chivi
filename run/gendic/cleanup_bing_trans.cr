require "colorize"

require "sqlite3"

DIC = DB.open("sqlite3:var/dicts/mtdic/base.dic")
at_exit { DIC.close }

names = DIC.query_all "select zstr from defns where xpos like '%NR%'", as: String
names = names.to_set

DIR = "var/dicts/outer"

cached = Hash(String, Array(String)).new { |h, k| h[k] = Array(String).new }

File.each_line("#{DIR}/btrans.tsv") do |line|
  next if line.empty?
  zstr, vstr = line.split('\t', 2)
  vstr = vstr.sub /^\s*(\*|,)\s*/, ""

  cached[zstr] << vstr unless vstr.empty?
end

puts "cached: #{cached.size}"

out_path = "#{DIR}/btrans-cleaned.tsv"

def downcase(a : String)
  return a if a.empty?

  String.build do |io|
    a.each_char_with_index do |char, i|
      io << (i == 0 ? char.downcase : char)
    end
  end
end

def capitalize(a : String)
  return a if a.empty?

  String.build do |io|
    a.each_char_with_index do |char, i|
      io << (i == 0 ? char.upcase : char)
    end
  end
end

def is_lower?(x : String)
  x[0].downcase == x[0]
end

File.open(out_path, "w") do |file|
  cached.each do |zstr, vals|
    vals.uniq!.reject! { |x| x =~ /\p{Han}/ || x =~ /[[:punct:]]/ }
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
      puts "#{zstr} => #{vstr}".colorize.red
    end

    file << zstr << '\t' << vstr << '\n'
  end
end
