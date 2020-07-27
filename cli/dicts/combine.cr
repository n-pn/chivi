# combine extraqt and localqt
require "json"

require "./utils/common"
require "./utils/clavis"

require "../../src/dictdb"
require "../../src/lookup/value_set"

puts "\n[Load counters]".colorize.cyan.bold

alias Counter = Hash(String, Int32)

def read_counter(file : String)
  Counter.from_json(File.read(Utils.inp_path(file)))
end

COUNT_WORDS = read_counter("counted/count-words.json")
COUNT_BOOKS = read_counter("counted/count-books.json")

ONDICTS = Utils.ondicts_words

puts "\n[Load history]".colorize.cyan.bold

CHECKED = Set(String).new
EXISTED = Set(String).new

Dir.glob(Utils.inp_path("localqt/logs/*.log")) do |file|
  puts "- load file: [#{file.colorize(:blue)}]"

  File.each_line(file) do |line|
    key = line.split("\t", 2).first

    CHECKED.add(key)
    EXISTED.add(key)
  end
end

inp_generic = Clavis.load("autogen/output/generic.txt", false)
inp_suggest = Clavis.load("autogen/output/suggest.txt", false)
inp_combine = Clavis.load("autogen/output/combine.txt", false)
inp_recycle = Clavis.load("autogen/output/recycle.txt", false)

puts "\n[Load localqt]".colorize.cyan

INPUT = Clavis.new("localqt.txt", false)

{
  "localqt/names2.txt",
  "localqt/names1*.txt",
  "localqt/vietphrase.txt",
}.each do |file|
  Clavis.load(file).each do |key, vals|
    EXISTED << key
    INPUT.upsert(key, vals, :old_first)
  end
end

# replace localqt with manually checked
Dir.glob(Utils.inp_path("localqt/fixes/*.txt")) do |file|
  Clavis.new(file).each do |key, vals|
    CHECKED.add(key)
    EXISTED.add(key)

    INPUT.upsert(key, vals, :keep_new)
  end
end

puts "- localqt: #{INPUT.size} entries.".colorize.blue

puts "\n[Parse localqt]".colorize.cyan.bold

INPUT.each do |key, vals|
  book_count = COUNT_BOOKS[key]? || 0
  word_count = COUNT_WORDS[key]? || 0

  checked = CHECKED.includes?(key)
  ondicts = ONDICTS.includes?(key)

  words, names = vals.uniq.partition { |x| x == x.downcase }
  words = words.first(4)
  names = names.first(4)

  unless words.empty?
    if (ondicts || word_count >= 100) && (checked || book_count >= 20)
      inp_generic.upsert(key, words)
    elsif checked || ondicts || book_count >= 10
      inp_suggest.upsert(key, words)
    elsif word_count >= 100 && key.size < 8
      inp_suggest.upsert(key, words)
    elsif word_count >= 10
      inp_recycle.upsert(key, words)
    end
  end

  unless names.empty?
    if (ondicts || word_count >= 200) && (checked || book_count >= 40)
      inp_generic.upsert(key, vals, :old_first)
    elsif checked || ondicts || book_count >= 10
      inp_suggest.upsert(key, vals, :old_first)
    elsif word_count >= 100 && key.size < 8
      inp_suggest.upsert(key, vals, :old_first)
    elsif word_count >= 10
      inp_recycle.upsert(key, vals, :old_first)
    end

    next unless words.empty? && key !~ /^\P{Han}/
    if checked || (book_count >= 20 && word_count >= 500)
      inp_combine.upsert(key, vals, :old_first)
    end
  end
end

puts "\n[Load persist]".colorize.cyan

Dir.glob(Utils.inp_path("manmade/*.txt")).each do |file|
  Clavis.new(file, true).each do |key, vals|
    CHECKED.add(key)
    EXISTED.add(key)

    if COUNT_WORDS.fetch(key, 0) >= 200
      inp_generic.upsert(key, vals, :new_first)
    else
      inp_suggest.upsert(key, vals, :new_first)
    end
  end
end

Dir.glob(Utils.inp_path("manmade/pop-fictions/*.txt")).each do |file|
  Clavis.new(file, true).each do |key, vals|
    CHECKED.add(key)
    EXISTED.add(key)

    if COUNT_BOOKS.fetch(key, 0) >= 20
      inp_generic.upsert(key, vals, :old_first)
    else
      inp_suggest.upsert(key, vals, :old_first)
    end
  end
end

puts "\n[Load suggest]".colorize.cyan

Dir.glob(Utils.inp_path("manmade/other-names/*.txt")).each do |file|
  Clavis.new(file, true).each do |key, vals|
    CHECKED.add(key)
    EXISTED.add(key)

    if COUNT_WORDS.fetch(key, 0) >= 50
      inp_suggest.upsert(key, vals, :old_first)
    else
      inp_recycle.upsert(key, vals, :old_first)
    end
  end
end

# # hanviet

puts "\n[Load hanviet]".colorize.cyan.bold

DictDB.hanviet.each do |node|
  next if CHECKED.includes?(node.key)
  EXISTED.add(node.key)

  if vals = inp_generic[node.key]?
    inp_generic.delete(node.key) if node.vals.first == vals.first
  end

  if vals = inp_suggest[node.key]?
    inp_suggest.delete(node.key) if node.vals.first == vals.first
  end
end

{"hanviet/lacviet-words.txt", "hanviet/trichdan-words.txt"}.each do |file|
  Clavis.load(file, true).each do |key, vals|
    EXISTED.add(key)
    if COUNT_WORDS.fetch(key, 0) >= 50
      inp_generic.upsert(key, vals, :old_first)
    else
      inp_suggest.upsert(key, vals, :old_first)
    end
  end
end

puts "\n[Load extraqt]".colorize.cyan.bold

Clavis.load("extraqt/combined-lowercase.txt").each do |key, vals|
  next if EXISTED.includes?(key)

  book_count = COUNT_BOOKS[key]? || 0
  word_count = COUNT_WORDS[key]? || 0

  ondicts = ONDICTS.includes?(key)

  if ondicts && book_count >= 20 && word_count >= 200
    inp_generic.upsert(key, vals, :old_first)
  elsif (ondicts || book_count >= 20) && word_count >= 100
    inp_suggest.upsert(key, vals, :old_first)
  elsif word_count >= 250
    inp_recycle.upsert(key, vals, :old_first)
  end
end

Clavis.load("extraqt/combined-uppercase.txt").each do |key, vals|
  next if EXISTED.includes?(key)

  book_count = COUNT_BOOKS[key]? || 0
  word_count = COUNT_WORDS[key]? || 0

  ondicts = ONDICTS.includes?(key)

  if ondicts && book_count >= 40 && word_count >= 400
    inp_generic.upsert(key, vals, :old_first)
  elsif (ondicts || book_count >= 20) && word_count >= 200
    inp_suggest.upsert(key, vals, :old_first)
  elsif word_count >= 250
    inp_recycle.upsert(key, vals, :old_first)
  end
end

puts "\n[Save temps]"

inp_generic.save!
inp_suggest.save!
inp_combine.save!
inp_recycle.save!

File.write(Utils.inp_path("autogen/checked.txt"), CHECKED.to_a.join("\n"))
File.write(Utils.inp_path("autogen/existed.txt"), EXISTED.to_a.join("\n"))
