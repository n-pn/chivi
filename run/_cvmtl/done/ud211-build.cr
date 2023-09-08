require "sqlite3"
require "../../src/mt_sp/engine"

record Term,
  line : Int32,
  lpos : Int32,
  word : String,
  upos : String,
  ptag : String,
  feats : String,
  head : Int32,
  deprel : String,
  deps : String,
  misc : String

def read_file(file : String, l_id = 0)
  res = [] of Term
  File.each_line(file) do |line|
    if line.empty?
      l_id += 1
      next
    end

    next if line.starts_with?('#')

    args = line.split('\t')

    res << Term.new(
      line: l_id,
      lpos: args[0].to_i,
      word: args[1],
      # lemma: args[1],
      upos: args[3],
      ptag: args[4],
      feats: args[5],
      head: args[6].to_i,
      deprel: args[7],
      deps: args[8],
      misc: args[9],
    )
  end

  {res, l_id}
end

alias Freq = Hash(String, Int32)
terms = [] of Term
freqs = Hash(String, Freq).new { |h, k| h[k] = Freq.new(0) }

HANVIET = Hash(String, String).new do |h, k|
  h[k] = SP::MtCore.tl_sinovi(k, cap: false)
end

l_id = 0

{"train", "dev", "test"}.each do |type|
  file = "var/inits/mt_v2/UD2/UD_Chinese-GSDSimp/zh_gsdsimp-ud-#{type}.conllu"
  array, l_id = read_file(file)
  terms.concat(array)
  array.each do |term|
    freqs[term.word][term.ptag] &+= 1
  end
end

puts terms.size
DB.open("sqlite3:var/mt_v2/dicts/ud211-data.db") do |db|
  db.exec "begin transaction"
  db.exec "delete from terms"

  terms.each do |term|
    args = {
      term.line,
      term.lpos,
      term.word,
      HANVIET[term.word],
      term.upos,
      term.ptag,
      term.feats,
      term.head,
      term.deprel,
      term.deps,
      term.misc,
    }

    db.exec <<-SQL, *args
      replace into terms(line, lpos, word, viet, upos, ptag, feats, head, deprel, deps, misc)
      values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    SQL
  end

  db.exec "commit"
end

puts freqs.size
DB.open("sqlite3:var/mt_v2/dicts/ud211-freq.db") do |db|
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
