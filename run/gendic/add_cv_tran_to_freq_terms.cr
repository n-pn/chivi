require "sqlite3"

defns = {} of String => String
bings = {} of String => String
prevs = {} of String => String

DB.open("sqlite3:/2tb/app.chivi/var/mtapp/v1dic/v1_defns.dic") do |db|
  sql = <<-SQL
  select key, val from defns
  where dic > -4 and val <> '' and _flag >= 0
  order by id asc, tab asc, id desc
  SQL

  db.query_each sql do |rs|
    key, val = rs.read(String, String)
    defns[key] ||= val
  end
end

DB.open("sqlite3:var/mtdic/fixed/defns/all_terms.dic") do |db|
  db.query_each "select zh, bi from terms where bi <> ''" do |rs|
    key, val = rs.read(String, String)
    bings[key] ||= val
  end
end

File.each_line("var/inits/vietphrase/combine-propers.tsv") do |line|
  key, val = line.split('\t', 2)
  prevs[key] = val.gsub('\t', 'ǀ')
end

output = [] of String
missing = [] of String
total = 0
exist = 0

defn_count = 0
bing_count = 0
prev_count = 0

File.each_line("var/mtdic/fixed/inits/regular-terms-cleaned.tsv") do |line|
  key = line.split('\t')[0]
  next if key =~ /^[\d+零〇一二两三四五六七八九十百千万亿]+(元|英寸)?$/
  next if key =~ /^第[\d+零〇一二两三四五六七八九十百千万亿]+章$/
  total += 1

  defn_count += 1 if defn = defns[key]?
  bing_count += 1 if bing = bings[key]?
  prev_count += 1 if prev = prevs[key]?

  if defn || bing || prev
    exist += 1
  else
    missing << key
  end

  output << "#{line}\t#{defn}\t#{bing}\t#{prev}"
end

puts "total: #{total}, existed: #{exist}, missing: #{missing.size}"
puts "defn: #{defn_count}, bing: #{bing_count}, prev: #{prev_count}"

File.write("var/dicts/inits/regular-terms-cv.tsv", output.join('\n'))
File.write("var/dicts/inits/regular-missing.tsv", missing.join('\n'))
