require "./_shared"

DIC = DB.open("sqlite3:#{MT::MtDefn.db_path("common-main")}")
at_exit { DIC.close }

missing = DIC.scalar "select count(*) from defns where vstr = ''"
puts "missing: #{missing}"

mains = {} of String => Array(String)
bings = {} of String => Array(String)
prevs = {} of String => Array(String)

DB.open("sqlite3:var/mtapp/v1dic/v1_defns.dic") do |db|
  sql = <<-SQL
  select key, val from defns
  where dic > -4 and val <> ''and _flag >= 0
  order by dic asc, tab asc, id desc
  SQL

  db.query_each sql do |rs|
    zstr, vstr = rs.read(String, String)
    vstr = vstr.split(/[ǀ|\t]/).map { |x| x.gsub(/\p{Cc}/, "").strip }
    next if vstr.first.empty?
    mains[normalize(zstr)] ||= vstr
  end
end

puts "main data: #{mains.size}"

File.each_line("var/mtdic/_temp/qt-known.tsv") do |line|
  zstr, *vstr = line.split('\t')
  prevs[normalize(zstr)] = vstr
end

puts "prev data: #{prevs.size}"

File.each_line("var/mtdic/_temp/bing-cleaned.tsv") do |line|
  zstr, *vstr = line.split('\t')
  bings[normalize(zstr)] ||= vstr
end

puts "bing data: #{bings.size}"

entries = [] of {String, String, String, Int32}

DIC.query_each "select zstr, xpos from defns where _flag < 4" do |rs|
  zstr, xpos = rs.read(String, String)
  nstr = normalize(zstr)

  vstr = uname = nil
  _flag = 0

  vmain = mains[nstr]? || [] of String
  vprev = prevs[nstr]? || [] of String

  if vbing = bings[nstr]?
    uname = "!bi"

    if found = vbing.find { |vstr| vstr.in?(vmain) || vstr.in?(vprev) }
      vstr = found
      _flag = 3
    else
      vstr = vbing.first
      _flag = 1
    end
  end

  if _flag < 3
    if !vmain.empty?
      vstr = vmain.first
      uname = "!cv"
      _flag = 3
    elsif !vprev.empty?
      vstr = vprev.first
      uname = "!qt"
      _flag = 2
    end
  end

  next unless vstr && uname && _flag

  puts "#{zstr} => #{vstr} (#{uname} / #{_flag})"
  entries << {zstr, vstr, uname, _flag}
end

update_stmt = "update defns set vstr = $1, uname = $2, _flag = $3 where zstr = $4"

DIC.exec "begin"

entries.each do |zstr, vstr, uname, _flag|
  DIC.exec update_stmt, vstr, uname, _flag, zstr
end

DIC.exec "commit"

missing = DIC.scalar "select count(*) from defns where vstr = ''"
puts "missing: #{missing}, filled: #{entries.size}"
