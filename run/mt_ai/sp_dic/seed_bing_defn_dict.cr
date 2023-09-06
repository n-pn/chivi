require "sqlite3"
require "../../src/mtapp/service/btran_api"

DIC = DB.open("sqlite3:var/dicts/hints/bing_dict.dic?journal_mode=WAL")
at_exit { DIC.close }

# DIC.exec "drop table if exists defns"
# DIC.exec <<-SQL
#   create table if not exists defns(
#     word varchar primary key,
#     ptag varchar default '',
#     sense text default '',
#     utime integer default 0
#   )
# SQL

# DIC.exec "begin"
# DIC.exec "attach database 'var/dicts/hints/all_terms.dic' as inp"
# DIC.exec "insert into defns (word) select zh as word from inp.terms where flag > 1 order by flag desc"
# DIC.exec "commit"

def add_lookup(input : Array(String))
  DIC.exec "begin"

  utime = Time.utc.to_unix

  stmt = "update defns set sense = $1, utime = $2 where word = $3"

  SP::Btran.lookup(input).each_with_index do |output, i|
    DIC.exec stmt, output.translations.to_json, utime, input[i]
  end

  DIC.exec "commit"
end

words = DIC.query_all "select word from defns where sense = ''", as: String
words.each_slice(10).each do |slice|
  puts slice
  add_lookup(slice)
  sleep 0.5
end
