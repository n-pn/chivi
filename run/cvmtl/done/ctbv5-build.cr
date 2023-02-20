require "sqlite3"
require "../../src/mt_sp/mt_core"

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
    l_id += 1
    chars, ptags = line.split('	', 2)

    chars = chars.split(' ')
    ptags = ptags.split(' ')

    raise "mismatch: #{chars.size} vs #{ptags.size}" unless chars.size == ptags.size

    lpos = 0

    chars.each_with_index do |char, i|
      ptag = ptags[i]

      bmes, tag = ptag.split('-', 2)

      case bmes
      when "B"
        terms << Term.new(l_id, lpos, char, tag)
      when "M"
        terms.last.word += char
      when "E"
        terms.last.word += char
        lpos += 1
      when "S"
        terms << Term.new(l_id, lpos, char, tag)
        lpos += 1
      else
        puts [file, l_id, line]
      end
    end
  end

  {terms, l_id + 1}
end

alias Freq = Hash(String, Int32)

terms = [] of Term

freqs = Hash(String, Freq).new { |h, k| h[k] = Freq.new(0) }

l_id = 0

{"train", "dev", "test"}.each do |type|
  array, l_id = read_file "var/inits/mt_v2/POS/ctb5/#{type}.char.bmes", l_id
  terms.concat(array)
  array.each do |term|
    freqs[term.word][term.ptag] &+= 1
  end
end

puts terms.size, freqs.size

HANVIET = Hash(String, String).new do |h, k|
  h[k] = SP::MtCore.tl_sinovi(k, cap: false)
end

DB.open("sqlite3:var/mt_v2/dicts/ctbv5-data.db") do |db|
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

DB.open("sqlite3:var/mt_v2/dicts/ctbv5-freq.db") do |db|
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
