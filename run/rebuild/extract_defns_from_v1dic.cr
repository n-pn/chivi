require "sqlite3"

DIC = DB.open "sqlite3:var/mtdic/users/v1_defns.dic"
at_exit { DIC.close }

def extract(dic = 0)
  terms = {} of String => Array(String)
  stmt = <<-SQL
    select key, val from defns
    where dic = #{dic} and tab >= 0 and tab < 2 and _flag >= 0
    order by mtime desc
  SQL

  DIC.query_each stmt do |rs|
    key, val = rs.read(String, String)
    terms[key] ||= [val]
  end

  terms
end

dics = DIC.query_all "select distinct(dic) from defns", as: Int32

common, unique = dics.partition(&.< 0)

generic = {} of String => Array(String)
common.sort_by!(&.-).each do |dic|
  next if dic == -11
  current = extract(dic)
  generic.merge!(current) { |k, a, b| a.concat(b) }

  puts "#{dic} => #{current.size} (#{generic.size})"
end

File.open("var/dicts/_temp/cv-generic.tsv", "w") do |file|
  generic.each do |key, vals|
    next if vals.first.empty?
    file << key << '\t' << vals.flat_map(&.split('ǀ').map(&.strip)).uniq!.join('\t') << '\n'
  end
end

special = {} of String => Array(String)
unique.sort!.each do |dic|
  current = extract(dic)
  special.merge!(current) { |k, a, b| a.concat(b) }
  puts "#{dic} => #{current.size} (#{generic.size})"
end

File.open("var/dicts/_temp/cv-special.tsv", "w") do |file|
  special.each do |key, vals|
    next if vals.first.empty?
    file << key << '\t' << vals.flat_map(&.split('ǀ').map(&.strip)).uniq!.join('\t') << '\n'
  end
end
