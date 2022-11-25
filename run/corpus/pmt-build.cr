require "sqlite3"
require "../../src/cvhlp/engine"

File.delete "var/cvmtl/dicts/pmt1.0.db"
DIC = DB.open("sqlite3:var/cvmtl/dicts/pmt1.0.db")
at_exit { DIC.close }

DIC.exec <<-SQL
  create table if not exists words(
    line integer,
    lpos integer,

    word varchar,
    ptag varchar,
    viet varchar,

    dep_name varchar,
    dep_lpos integer,

    primary key (line, lpos)
  )
SQL

DIC.exec <<-SQL
  create table if not exists freqs(
    word varchar,
    ptag varchar,
    viet varchar,
    freq integer default 0,
    primary key (word, ptag)
  )
SQL

DIC.exec "create index if not exists words_word_idx on words(word);"
DIC.exec "create index if not exists words_ptag_idx on words(ptag);"
DIC.exec "create index if not exists words_rule_idx on words(dep_name);"

DIC.exec "create index if not exists freqs_word_idx on freqs(word);"
DIC.exec "create index if not exists freqs_ptag_idx on freqs(ptag);"

lines = File.read_lines("var/inits/cvmtl/199801_dependency_treebank_2003pos.txt")

limit = lines.size // 5

record Entry, line : Int32, lpos : Int32, word : String, ptag : String, viet : String,
  dep_name : String, dep_lpos : Int32

alias Count = Hash(String, Int32)

entries = [] of Entry
freqs = Hash(String, Count).new { |h, k| h[k] = Count.new(0) }

hanviet = Hash(String, String).new do |h, k|
  h[k] = TL::Engine.hanviet.convert(k).to_txt(cap: false)
end

1.upto(limit - 1) do |line_id|
  words = lines[line_id * 5].strip.split('\t')
  ptags = lines[line_id * 5 + 1].strip.split('\t')
  dep_names = lines[line_id * 5 + 2].strip.split('\t')
  dep_lposs = lines[line_id * 5 + 3].strip.split('\t')

  words.each_with_index do |word, i|
    freqs[word][ptags[i]] &+= 1

    entries << Entry.new(
      line_id,
      i + 1,
      word,
      ptags[i],
      hanviet[word],
      dep_names[i],
      dep_lposs[i].to_i
    )
  end
end

DIC.transaction do |tx|
  db = tx.connection

  entries.each do |entry|
    db.exec <<-SQL, entry.line, entry.lpos, entry.word, entry.ptag, entry.viet, entry.dep_name, entry.dep_lpos
      replace into words values(?, ?, ?, ?, ?, ?, ?)
    SQL
  end

  freqs = freqs.to_a.map do |k, v|
    v = v.to_a.sort_by!(&.[1].-)
    sum = v.reduce(0) { |c, (_, i)| c + i }
    {k, v, sum}
  end

  freqs.sort_by!(&.[2].-)

  freqs.each do |word, count, _sum|
    count.each do |ptag, freq|
      db.exec <<-SQL, word, ptag, hanviet[word], freq
        replace into freqs values(?, ?, ?, ?)
      SQL
    end
  end
end
