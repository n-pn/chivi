require "sqlite3"
require "../../src/mt_sp/engine"

# lines = File.read_lines("var/inits/mt_v2/input/199801.txt", encoding: "GB18030")
lines = File.read_lines("var/inits/mt_v2/input/199801_people_s_daily.txt")

class Term
  getter lpos : Int32
  getter word : String
  getter ptag : String

  property line : Int32 = 0
  property comp : String = ""

  def initialize(@lpos, @word, @ptag)
  end

  def inspect(io : IO)
    {word, ptag, comp}.join(io, '/')
  end
end

RE1 = /^(.+?)\/(\w+)$/
RE2 = /^(.+?)\/(\w+)\](\w+)$/

def split_part(part : String)
  if match = RE2.match(part)
    {match[1], match[2], match[3]}
  elsif match = RE1.match(part)
    {match[1], match[2], ""}
  else
    raise "Invalid: `#{part}`"
  end
end

def parse_line(line : String)
  args = line.split /\s+/
  args.shift # remove line count

  terms = [] of Term
  comps = [] of Term

  args.each_with_index do |part, lpos|
    if part.starts_with?('[') && part[1]? != '/'
      word, ptag, _ = split_part(part[1..])
      comps << Term.new(lpos, word, ptag)
      next
    end

    word, ptag, comp_ptag = split_part(part)
    term = Term.new(lpos, word, ptag)

    if comps.empty?
      terms << term
    else
      comps << term
      next if comp_ptag.empty?

      comps.first.comp = "B-#{comp_ptag}"
      comps.last.comp = "E-#{comp_ptag}"
      comps[1...-1].each(&.comp = "M-#{comp_ptag}")

      terms.concat(comps)
      comps.clear
    end
  end

  terms
end

alias Freq = Hash(String, Int32)

words = [] of Term

freqs = Hash(String, Freq).new { |h, k| h[k] = Freq.new(0) }

l_id = 0

lines.each do |line|
  line = line.strip
  next if line.empty?

  l_id += 1

  parse_line(line).each do |term|
    freqs[term.word][term.ptag] &+= 1

    term.line = l_id
    words << term
  end

  # break if l_id > 20
end

puts words.size, freqs.size

HANVIET = Hash(String, String).new do |h, k|
  h[k] = SP::MtCore.tl_sinovi(k, cap: false)
end

DB.open("sqlite3:var/mt_v2/dicts/pku98-data.db") do |db|
  db.exec "begin transaction"
  db.exec "delete from terms"

  words.each do |word|
    viet = HANVIET[word.word]
    args = {word.line, word.lpos, word.word, word.ptag, viet, word.comp}
    db.exec <<-SQL, *args
      replace into terms(line, lpos, word, ptag, viet, comp) values(?, ?, ?, ?, ?, ?)
    SQL
  end

  db.exec "commit"
end

DB.open("sqlite3:var/mt_v2/dicts/pku98-freq.db") do |db|
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
