require "sqlite3"
require "../../src/mt_sp/engine"

lines = File.read_lines("var/inits/mt_v2/input/2014_corpus.txt")

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
RE2 = /^(.+?)\/(\w+?)\]\/(\w+)$/

def split_part(part : String)
  if match = RE2.match(part)
    {match[1], match[2], match[3]}
  elsif match = RE1.match(part)
    {match[1], match[2], ""}
  elsif part =~ /^\w+/
    {part, "xx", ""}
  else
    raise "Invalid: `#{part}`"
  end
end

RE3 = /^(\p{P}+)(.*)/

def split_line(line : String)
  output = [] of String

  line.split(/\s/).each do |part|
    next if part.empty?

    if part[1]? == '/' || !(match = RE3.match(part))
      output << part
      next
    end

    if part[0] == '['
      output << "[" << part[1..]
      next
    end

    _, punct, extra = match
    output << "#{punct}/w"
    output << extra unless extra.empty?
  end

  output
end

def parse_line(line : String)
  output = [] of Term

  lpos = 0
  comp_lpos = -1

  args = split_line(line)
  args.each do |part|
    if part == "["
      comp_lpos = lpos
      next
    end

    lpos += 1
    word, ptag, comp_ptag = split_part(part)
    term = Term.new(lpos, word, ptag)

    output << term
    next if comp_lpos < 0 || comp_ptag.empty?

    term.comp = "E-#{comp_ptag}"

    output[comp_lpos].comp = "B-#{comp_ptag}"
    output[(comp_lpos + 1)..-2].each(&.comp = "M-#{comp_ptag}")

    comp_lpos = -1
  end

  output
rescue err
  puts err, line
  exit 1
end

alias Freq = Hash(String, Int32)

l_id = 0
terms = [] of Term
freqs = Hash(String, Freq).new { |h, k| h[k] = Freq.new(0) }

lines.each do |line|
  line = line.strip
  next if line.empty?

  l_id += 1

  parse_line(line).each do |term|
    freqs[term.word][term.ptag] &+= 1
    term.line = l_id
    terms << term
  end

  # break if l_id > 20
end

puts terms.size

HANVIET = Hash(String, String).new do |h, k|
  h[k] = SP::MtCore.tl_sinovi(k, cap: false)
end

DB.open("sqlite3:var/mt_v2/dicts/pku14-data.db") do |db|
  db.exec "begin transaction"
  db.exec "delete from terms"

  terms.each do |term|
    viet = HANVIET[term.word]
    args = {term.line, term.lpos, term.word, term.ptag, viet, term.comp}
    db.exec <<-SQL, *args
      replace into terms(line, lpos, word, ptag, viet, comp) values(?, ?, ?, ?, ?, ?)
    SQL
  end

  db.exec "commit"
end

puts freqs.size
DB.open("sqlite3:var/mt_v2/dicts/pku14-freq.db") do |db|
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
