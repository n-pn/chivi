require "sqlite3"
require "../../src/mt_sp/engine"

class Term
  property line : Int32 = 0
  property lpos : Int32
  property word : String
  property ptag : String

  def initialize(@line, @lpos, @word, @ptag)
  end

  def inspect(io : IO)
    {word, ptag}.join(io, '/')
  end
end

def read_file(file : String, l_id = 0)
  terms = [] of Term
  lines = File.read_lines(file)

  lines.each do |line|
    line = line.strip
    next if line[0]?.in?(nil, '<')

    l_id += 1

    parts = line.split(' ')
    parts.each_with_index do |part, lpos|
      word, ptag = part.split('_')
      terms << Term.new(l_id, lpos, word, ptag)
    end
  end

  {terms, l_id + 1}
end

alias Freq = Hash(String, Int32)

freqs = Hash(String, Freq).new { |h, k| h[k] = Freq.new(0) }
terms = [] of Term

files = Dir.glob("var/inits/mt_v2/ctb8.0/data/postagged/*.pos")

files.sort_by! do |x|
  name = File.basename(x, ".pos")
  name.split(/[_.]/)[1].to_i
end

l_id = 0
files.each do |file|
  array, l_id = read_file file, l_id
  terms.concat(array)
  array.each do |term|
    freqs[term.word][term.ptag] &+= 1
  end
end

puts terms.size, freqs.size

HANVIET = Hash(String, String).new do |h, k|
  h[k] = SP::MtCore.tl_sinovi(k, cap: false)
end

DB.open("sqlite3:var/mt_v2/dicts/ctbv8-data.db") do |db|
  db.exec "begin transaction"
  db.exec "delete from terms"

  terms.each do |word|
    viet = HANVIET[word.word]
    args = {word.line, word.lpos, word.word, word.ptag, viet}
    db.exec <<-SQL, *args
      replace into terms(line, lpos, word, ptag, viet) values(?, ?, ?, ?, ?)
    SQL
  end

  db.exec "commit"
end

DB.open("sqlite3:var/mt_v2/dicts/ctbv8-freq.db") do |db|
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
      args = {word, ptag, HANVIET[word], freq}
      db.exec <<-SQL, *args
        replace into freqs(word, ptag, viet, freq) values(?, ?, ?, ?)
      SQL
    end
  end

  db.exec "commit"
end
