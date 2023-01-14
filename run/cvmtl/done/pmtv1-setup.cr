require "sqlite3"

# File.delete "var/mt_v2/dicts/pmt1.0.db"

DB.open("sqlite3:var/mt_v2/dicts/pmtv1-data.db") do |db|
  db.exec <<-SQL
    create table if not exists terms(
      line integer,
      lpos integer,

      word varchar,
      viet varchar,

      ptag varchar,

      dep_name varchar,
      dep_lpos integer,

      primary key (line, lpos)
    )
  SQL

  db.exec "create index if not exists terms_word_idx on terms(word);"
  db.exec "create index if not exists terms_ptag_idx on terms(ptag);"
  db.exec "create index if not exists terms_rule_idx on terms(dep_name);"
end

DB.open("sqlite3:var/mt_v2/dicts/pmtv1-freq.db") do |db|
  db.exec <<-SQL
    create table if not exists freqs(
      word varchar,
      viet varchar,

      ptag varchar,
      freq integer default 0,
      primary key (word, ptag)
    )
  SQL

  db.exec "create index if not exists freqs_word_idx on freqs(word);"
  db.exec "create index if not exists freqs_ptag_idx on freqs(ptag);"
end
