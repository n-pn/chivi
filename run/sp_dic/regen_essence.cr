require "../../src/mtapp/sp_core/sp_defn"
require "../../src/mtapp/shared/fmt_flag"

DNAME = "essence"
MT::SpDefn.init_db(DNAME, reset: false)

terms = [] of MT::SpDefn

DB.open("sqlite3:var/mtdic/users/v1_defns.dic") do |db|
  stmt = <<-SQL
    select "key", val, uname, mtime from defns
    where dic = ? order by mtime asc, "key" asc
  SQL

  db.query_each(stmt, -2) do |rs|
    zstr, vstr, uname, mtime = rs.read(String, String, String, Int32)
    vals = vstr.split(/[|ǀ\t]/).map!(&.strip).reject(&.empty?)

    next unless vstr = vals.first?
    fmt = zstr.size == 1 ? MT::FmtFlag.auto_detect(zstr).to_i : 0

    terms << MT::SpDefn.new(zstr: zstr, vstr: vstr, _fmt: fmt, uname: uname, mtime: mtime)
  end
end

puts "total: #{terms.size}"

MT::SpDefn.open_db(DNAME) do |db|
  db.exec "begin"
  terms.each(&.save!(db))
  db.exec "commit"
end
