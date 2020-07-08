# combine extraqt and localqt
require "json"

require "./utils/common"
require "./utils/clavis"

require "../../src/engine/cv_dict"
require "../../src/kernel/value_set"

puts "[Load counters]".colorize(:cyan)

alias Counter = Hash(String, Int32)

def read_counter(file : String)
  Counter.from_json(File.read(file))
end

COUNT_WORDS = read_counter(Utils.inp_path("counted/count-words.json"))
COUNT_BOOKS = read_counter(Utils.inp_path("counted/count-books.json"))

KNOWNED = ValueSet.load(Utils.inp_path("autogen/known-words.txt"))

puts "\n[Load history]".colorize(:cyan)

CHECKED = Set(String).new
EXISTED = Set(String).new

Dir.glob(Utils.inp_path("localqt/mlogs/*.log")) do |file|
  puts "- load file: [#{file.colorize(:blue)}]"

  File.read_lines(file)[1..].each do |line|
    key = line.split("\t", 2).first
    CHECKED.add key.as(String)
    EXISTED.add key.as(String)
  end
end

REJECTS = {"的", "了", "是", ",", ".", "!"}

def should_skip?(word : String)
  return false if KNOWNED.includes?(word)
  return true unless word =~ /\p{Han}/
  return true if word =~ /^第?.+[章节幕回集卷]$/
  return false if word.ends_with?("目的")

  REJECTS.each do |char|
    return true if word.starts_with?(char) || word.ends_with?(char)
  end

  false
end

def split_val(val : String)
  val.split(/[\/|]/)
    .map(&.strip)
    .reject(&.empty?)
    .reject(&.includes?(":"))
end

inp_generic = Clavis.new(Utils.inp_path("autogen/generic.txt"))
inp_suggest = Clavis.new(Utils.inp_path("autogen/suggest.txt"))
inp_combine = Clavis.new(Utils.inp_path("autogen/combine.txt"))
inp_recycle = Clavis.new(Utils.inp_path("autogen/recycle.txt"))

puts "\n[Load localqt]".colorize(:cyan)

localqt = Clavis.new("localqt.txt", false)

Dir.glob(Utils.inp_path("localqt/*.txt")) do |file|
  Clavis.new(file).each do |key, vals|
    EXISTED << key
    next if should_skip?(key)
    localqt.upsert(key, vals, :old_first)
  end
end

# replace localqt with manually checked
Dir.glob(Utils.inp_path("localqt/fixes/*.txt")) do |file|
  Clavis.new(file).each do |key, vals|
    CHECKED.add(key)
    EXISTED.add(key)
    localqt.upsert(key, vals, :keep_new)
  end
end

puts "- localqt: #{localqt.size} entries.".colorize(:cyan)

puts "\n[Parse localqt]".colorize(:cyan)

localqt.each do |key, vals|
  book_count = COUNT_BOOKS[key]? || 0
  word_count = COUNT_WORDS[key]? || 0

  checked = CHECKED.includes?(key)
  knowned = KNOWNED.includes?(key)

  words, names = vals.uniq.partition { |x| x == x.downcase }
  words = words.first(4)
  names = names.first(4)

  unless words.empty?
    if (knowned || word_count >= 200) && (checked || book_count >= 20)
      inp_generic.upsert(key, words)
    elsif (checked || knowned) && word_count >= 20
      inp_suggest.upsert(key, words)
    elsif word_count >= 100 && key.size < 8
      inp_suggest.upsert(key, words)
    elsif word_count >= 10
      inp_recycle.upsert(key, words)
    end
  end

  unless names.empty?
    if (knowned || word_count >= 200) && (checked || book_count >= 20) && words.empty?
      inp_generic.upsert(key, vals, :new_first)
    elsif (checked || knowned) && word_count >= 20
      inp_suggest.upsert(key, vals, :new_first)
    elsif word_count >= 100 && key.size < 8
      inp_suggest.upsert(key, vals, :new_first)
    elsif word_count >= 10
      inp_recycle.upsert(key, vals, :new_first)
    end

    next if key =~ /^\P{Han}/ || inp_generic.has_key?(key)
    if (checked && word_count >= 50) || book_count >= 20
      inp_combine.upsert(key, vals, :new_first)
    end
  end
end

puts "\n[Load persist]".colorize(:cyan)

Dir.glob(Utils.inp_path("manmade/*.txt")).each do |file|
  Clavis.new(file, true).each do |key, vals|
    CHECKED.add(key)
    EXISTED.add(key)

    if COUNT_WORDS.fetch(key, 0) > 10
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

    if COUNT_BOOKS.fetch(key, 0) > 10
      inp_generic.upsert(key, vals, :old_first)
    else
      inp_suggest.upsert(key, vals, :old_first)
    end
  end
end

puts "\n[Load suggest]".colorize(:cyan)

Dir.glob(Utils.inp_path("manmade/other-names/*.txt")).each do |file|
  Clavis.new(file, true).each do |key, vals|
    CHECKED.add(key)
    EXISTED.add(key)

    if COUNT_WORDS.fetch(key, 0) > 10
      inp_suggest.upsert(key, vals, :old_first)
    else
      inp_recycle.upsert(key, vals, :old_first)
    end
  end
end

# # hanviet

puts "\n[Load hanviet]".colorize(:cyan)

CvDict.load(Utils.out_path("shared/hanviet.dic")).each do |node|
  next if CHECKED.includes?(node.key)
  EXISTED.add(node.key)

  if vals = inp_generic[node.key]?
    inp_generic.delete(node.key) if node.vals.first == vals.first
  end

  if vals = inp_suggest[node.key]?
    inp_suggest.delete(node.key) if node.vals.first == vals.first
  end
end

Clavis.new(Utils.inp_path("hanviet/lacviet-words.txt")).each do |key, vals|
  EXISTED.add(key)

  if COUNT_WORDS.fetch(key, 0) > 10
    inp_generic.upsert(key, vals, :old_first)
  else
    inp_suggest.upsert(key, vals, :old_first)
  end
end

Clavis.new(Utils.inp_path("hanviet/trichdan-words.txt")).each do |key, vals|
  EXISTED.add(key)

  if COUNT_WORDS.fetch(key, 0) > 10
    inp_generic.upsert(key, vals, :old_first)
  else
    inp_suggest.upsert(key, vals, :old_first)
  end
end

puts "\n[Load extraqt]".colorize(:cyan)

Clavis.new(Utils.inp_path("extraqt/combined-lowercase.txt")).each do |key, vals|
  next if EXISTED.includes?(key)

  book_count = COUNT_BOOKS[key]? || 0
  word_count = COUNT_WORDS[key]? || 0

  knowned = KNOWNED.includes?(key)

  if (knowned && book_count >= 50 && word_count >= 100)
    inp_generic.upsert(key, vals, :old_first)
  elsif (knowned && word_count >= 100) || (word_count >= 500 && book_count >= 50)
    if key.size < 7
      inp_suggest.upsert(key, vals, :old_first)
    else
      inp_recycle.upsert(key, vals, :old_first)
    end
  elsif word_count >= 500
    inp_recycle.upsert(key, vals, :old_first)
  end
end

Clavis.new(Utils.inp_path("extraqt/combined-uppercase.txt")).each do |key, vals|
  next if EXISTED.includes?(key)

  book_count = COUNT_BOOKS[key]? || 0
  word_count = COUNT_WORDS[key]? || 0

  knowned = KNOWNED.includes?(key)

  if (knowned && book_count >= 50 && word_count >= 100)
    inp_generic.upsert(key, vals, :old_first)
  elsif (knowned && word_count >= 50) || (word_count >= 200 && book_count >= 20)
    inp_suggest.upsert(key, vals, :old_first)
  elsif word_count >= 250
    inp_recycle.upsert(key, vals, :old_first)
  end

  if word_count >= 2000
    next if inp_generic.includes?(key)
    inp_combine.upsert(key, vals, :old_first)
  end
end

puts "\n[Save temps]"

inp_generic.save!
inp_suggest.save!
inp_combine.save!
inp_recycle.save!

File.write(Utils.inp_path("autogen/checked.txt"), CHECKED.to_a.join("\n"))
File.write(Utils.inp_path("autogen/existed.txt"), EXISTED.to_a.join("\n"))
