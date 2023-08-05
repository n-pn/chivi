require "../../src/mtapp/sp_core/sp_defn"

DNAME = "sino_vi"
MT::SpDefn.init_db(DNAME, reset: false)

terms = [] of MT::SpDefn

DB.open("sqlite3:var/mtapp/v1dic/v1_defns.dic") do |db|
  stmt = <<-SQL
    select "key", val, uname, mtime from defns
    where dic = ? order by mtime asc, "key" asc
  SQL

  db.query_each(stmt, -10) do |rs|
    zstr, vstr, uname, mtime = rs.read(String, String, String, Int32)
    vals = vstr.split(/[|ǀ\t]/).map!(&.strip).reject(&.empty?)

    next unless vstr = vals.first?
    terms << MT::SpDefn.new(zstr: zstr, vstr: vstr, uname: uname, mtime: mtime)
  end
end

puts "total: #{terms.size}"

MT::SpDefn.open_db(DNAME) do |db|
  db.exec "begin"
  terms.each(&.save!(db))
  db.exec "commit"
end
