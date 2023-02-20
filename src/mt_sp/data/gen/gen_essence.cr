require "../sp_term"

DNAME = "essence"
SP::SpTerm.init_db(DNAME, reset: true)

sql = <<-SQL
select "key", val, uname, mtime from defns
where dic = ? order by mtime asc, "key" asc
SQL

terms = [] of SP::SpTerm
DB.open("sqlite3:var/dicts/v1raw/v1_defns.dic") do |db|
  db.query_each(sql, -2) do |rs|
    key, val, uname, mtime = rs.read(String, String, String, Int64)
    next if key == val

    defs = val.split(/[|ǀ]/).map!(&.strip).reject!(&.empty?).uniq!.join('\t')
    terms << SP::SpTerm.new(zstr: key, defs: defs, uname: uname, mtime: mtime)
  end
end

upsert_sql = SP::SpTerm.upsert_sql

DIC = SP::SpTerm.open_db(DNAME)
at_exit { DIC.close }

DIC.exec "begin"

terms.each do |term|
  DIC.exec(upsert_sql, *term.db_values)
end

DIC.exec "commit"
