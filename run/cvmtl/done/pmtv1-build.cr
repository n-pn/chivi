require "sqlite3"
require "../../src/mt_sp/engine"

lines = File.read_lines("var/inits/mt_v2/199801_dependency_treebank_2003pos.txt")

limit = lines.size // 5

record Entry, line : Int32, lpos : Int32, word : String, ptag : String,
  dep_name : String, dep_lpos : Int32

alias Count = Hash(String, Int32)

entries = [] of Entry
freqs = Hash(String, Count).new { |h, k| h[k] = Count.new(0) }

HANVIET = Hash(String, String).new do |h, k|
  h[k] = SP::MtCore.tl_sinovi(k, cap: false)
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
      dep_names[i],
      dep_lposs[i].to_i
    )
  end
end

DB.open("sqlite3:var/mt_v2/dicts/pmtv1-data.db") do |db|
  db.exec "begin transaction"
  db.exec "delete from terms"

  entries.each do |entry|
    args = {entry.line, entry.lpos, entry.word, HANVIET[entry.word], entry.ptag, entry.dep_name, entry.dep_lpos}
    db.exec <<-SQL, *args
      replace into terms(line, lpos, word, viet, ptag, dep_name, dep_lpos) values(?, ?, ?, ?, ?, ?, ?)
    SQL
  end

  db.exec "commit"
end

DB.open("sqlite3:var/mt_v2/dicts/pmtv1-freq.db") do |db|
  freqs = freqs.to_a.map do |k, v|
    v = v.to_a.sort_by!(&.[1].-)
    sum = v.reduce(0) { |c, (_, i)| c + i }
    {k, v, sum}
  end

  freqs.sort_by!(&.[2].-)
  db.exec "begin transaction"
  db.exec "delete from freqs"

  freqs.each do |word, count, _sum|
    count.each do |ptag, freq|
      args = {word, HANVIET[word], ptag, freq}
      db.exec <<-SQL, *args
        replace into freqs(word, viet, ptag, freq) values(?, ?, ?, ?)
      SQL
    end
  end

  db.exec "commit"
end
