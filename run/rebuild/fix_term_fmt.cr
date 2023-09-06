require "./_shared"

DIC = DB.open("sqlite3:#{MT::DbTerm.db_path("common-main")}")
at_exit { DIC.close }

input = DIC.query_all <<-SQL, as: String
  select zstr from defns where xpos = 'PU' or upos = 'w'
  SQL

puts input

DIC.exec "begin"
input.each do |zstr|
  zstr = zstr.chars.map { |char| CharUtil.normalize(char) }.join

  fmt = MT::FmtFlag.auto_detect(zstr)
  DIC.exec "update defns set _fmt = $1 where zstr = $2", fmt.to_i, zstr
end
DIC.exec "commit"
