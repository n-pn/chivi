require "./_shared"

DIC = DB.open("sqlite3:#{MT::MtDefn.db_path("base")}")
at_exit { DIC.close }

missing = DIC.scalar "select count(*) from defns where vstr = ''"
puts "missing: #{missing}"

mains = {} of String => Array(String)
bings = {} of String => Array(String)
prevs = {} of String => Array(String)

DB.open("sqlite3:var/dicts/v1raw/v1_defns.dic") do |db|
  sql = <<-SQL
  select key, val from defns
  where dic > -4 and _flag >= 0
  order by dic asc, tab asc, id desc
  SQL

  db.query_each sql do |rs|
    zstr, vstr = rs.read(String, String)
    next if vstr.empty?

    mains[normalize(zstr)] ||= vstr.split('ǀ').map(&.strip)
  end
end

puts "main data: #{mains.size}"

File.each_line("var/dicts/outer/btrans-cleaned.tsv") do |line|
  zstr, *vstr = line.split('\t')
  bings[normalize(zstr)] ||= vstr
end

puts "bing data: #{bings.size}"

# File.each_line("var/inits/vietphrase/combine-propers.tsv") do |line|
#   key, val = line.split('\t', 2)
#   prevs[key] = val.gsub('\t', 'ǀ')
# end

update_stmt = "update defns set vstr = $1, uname = $2, _flag = $3 where zstr = $4"

DIC.exec "begin"
DIC.query_each "select zstr, xpos from defns where _flag < 4" do |rs|
  zstr, xpos = rs.read(String, String)
  nstr = normalize(zstr)
  vstr = uname = nil

  if from_cv = mains[nstr]?
    vzstr = from_cv.first
    uname = "!cv"
    _flag = 3
  elsif from_bi = bings[nstr]?
    vzstr = from_bi.first
    uname = "!bi"
    _flag = 2
  elsif zstr !~ /\p{Han}/
    puts zstr
  end

  next unless vstr && uname && _flag
  DIC.exec update_stmt, vstr, uname, _flag, zstr
end

DIC.exec "commit"

missing = DIC.scalar "select count(*) from defns where vstr = ''"
puts "missing: #{missing}"
