require "./_shared"

DIC = DB.open("sqlite3:#{MT::DbTerm.db_path("common-main")}")
at_exit { DIC.close }

entries = [] of {String, String, Int32}

DIC.query_each "select zstr, xpos from defns" do |rs|
  zstr, xpos = rs.read(String, String)
  next if zstr =~ /\p{Han}/

  vstr = normalize(zstr)
  _fmt = xpos == "PU" ? MT::FmtFlag.detect(vstr).value.to_i : 0

  entries << {zstr, vstr, _fmt}
end

puts "updating: #{entries.size}"

stmt = "update defns set vstr = $1, _fmt = $2, uname = '!zh', _flag = 5 where zstr = $3"

DIC.exec "begin"
entries.each do |zstr, vstr, _fmt|
  DIC.exec stmt, vstr, _fmt, zstr
end
DIC.exec "commit"
