# combine extraqt and localqt
require "json"

require "../../src/_utils//normalize"
require "./shared/cvdict"

puts "[Load deps]".colorize(:cyan)

INP_DIR = File.join("data", ".inits", "dic-inp")
TMP_DIR = File.join("data", ".inits", "dic-tmp")
OUT_DIR = File.join("data", "cv_dicts")

alias Counter = Hash(String, Int32)

COUNT_WORDS = Counter.from_json File.read("#{INP_DIR}/counter/words.json")
COUNT_BOOKS = Counter.from_json File.read("#{INP_DIR}/counter/books.json")

ONDICTS = Set(String).new File.read_lines("#{INP_DIR}/lexicon.txt")

puts "\n[Load history]".colorize(:cyan)

CHECKED = Set(String).new
EXISTED = Set(String).new

Dir.glob("#{INP_DIR}/localqt/*.log") do |file|
  puts "- load file: [#{file.colorize(:blue)}]"

  File.read_lines(file)[1..].each do |line|
    key = line.split("\t", 2).first
    CHECKED.add key.as(String)
    EXISTED.add key.as(String)
  end
end

REJECTS = ["的", "了", "是", ",", ".", "!"]

def should_skip?(key : String)
  return false if ONDICTS.includes?(key)
  return true if key !~ /\p{Han}/
  return true if key =~ /^第?.+[章节幕回集卷]$/

  REJECTS.each do |char|
    return true if key.starts_with?(char) || key.ends_with?(char)
  end

  false
end

def split_val(val : String)
  val.split(/[\/|]/)
    .map(&.strip)
    .reject(&.empty?)
    .reject(&.includes?(":"))
end

def read_file(file)
  File.read_lines(file).compact_map do |line|
    begin
      key, val = line.split "=", 2
      {Utils.normalize(key).join, split_val(val)}
    rescue
      nil
    end
  end
end

generic_root = Cvdict.new("#{OUT_DIR}/core_root/generic.dic")
suggest_root = Cvdict.new("#{OUT_DIR}/core_root/suggest.dic")
combine_root = Cvdict.new("#{OUT_DIR}/core_root/combine.dic")
recycle_root = Cvdict.new("#{OUT_DIR}/core_root/recycle.dic")

puts "\n[Load localqt]".colorize(:cyan)

INPUT = Hash(String, Set(String)).new { |h, k| h[k] = Set(String).new }
# WORDS = Dict.new { |h, k| h[k] = Set(String).new }

Dir.glob("#{INP_DIR}/localqt/*.txt") do |file|
  puts "- load file: [#{file.colorize(:blue)}]"

  read_file(file).each do |key, vals|
    EXISTED.add key.as(String)
    next if should_skip?(key)
    INPUT[key].concat(vals) unless vals.empty?
  end
end

# replace localqt with manually checked
Dir.glob("#{INP_DIR}/localqt/replace/*.txt") do |file|
  puts "- load file: [#{file.colorize(:blue)}]"

  read_file(file).each do |key, vals|
    CHECKED.add(key)
    EXISTED.add(key)
    INPUT[key].clear.concat(vals)
  end
end

INPUT.each do |key, vals|
  book_count = COUNT_BOOKS[key]? || 0
  word_count = COUNT_WORDS[key]? || 0

  checked = CHECKED.includes?(key)
  ondicts = ONDICTS.includes?(key)

  words, names = vals.partition { |x| x == x.downcase }
  words = words.first(4)
  names = names.first(4)

  unless words.empty?
    if (ondicts || word_count >= 100) && (checked || book_count >= 20)
      generic_root.set(key, words, :keep_new)
    elsif checked || ondicts || word_count >= 100
      suggest_root.set(key, words, :keep_new) if words[0].split(" ").size < 8
    elsif word_count >= 5
      recycle_root.set(key, words, :keep_new)
    end
  end

  unless names.empty?
    if (ondicts || word_count >= 100) && book_count >= 20 && words.empty?
      generic_root.set(key, names, :new_first)
    elsif checked || ondicts || word_count >= 20
      suggest_root.set(key, names, :new_first) if names[0].split(" ").size < 8
    elsif word_count >= 5
      recycle_root.set(key, names, :new_first)
    end

    next if key =~ /^\P{Han}/ || generic_root.includes?(key)
    if (checked && word_count >= 50) || book_count >= 20
      combine_root.set(key, names, :old_first)
    end
  end
end

puts "\n[Load generic]".colorize(:cyan)

Dir.glob("#{INP_DIR}/persist/generic/**/*.txt").each do |file|
  Cvdict.load!(file).data.each do |key, val|
    generic_root.set(key, val, :new_first)

    CHECKED.add(key)
    EXISTED.add(key)
  end
end

puts "\n[Load suggest]".colorize(:cyan)

Dir.glob("#{INP_DIR}/persist/suggest/*.txt").each do |file|
  Cvdict.load!(file).data.each do |key, val|
    suggest_root.set(key, val, :old_first) unless generic_root.includes?(key)
    EXISTED.add(key)
  end
end

puts "\n[Load extraqt]".colorize(:cyan)

Cvdict.load!("#{INP_DIR}/extraqt/words.txt").data.each do |key, val|
  next if EXISTED.includes?(key)

  book_count = COUNT_BOOKS[key]? || 0
  word_count = COUNT_WORDS[key]? || 0

  ondicts = ONDICTS.includes?(key)

  if (ondicts && book_count >= 50)
    generic_root.set(key, val, :old_first)
  elsif (ondicts && word_count >= 100) || (word_count >= 500 && book_count >= 50)
    suggest_root.set(key, val, :old_first) if val[0].split(" ").size < 6
  elsif word_count >= 500
    recycle_root.set(key, val, :old_first)
  end
end

Cvdict.load!("#{INP_DIR}/extraqt/names.txt").data.each do |key, val|
  next if key.size == 1
  next if EXISTED.includes?(key)

  book_count = COUNT_BOOKS[key]? || 0
  word_count = COUNT_WORDS[key]? || 0

  ondicts = ONDICTS.includes?(key)

  if (ondicts && book_count >= 50)
    generic_root.set(key, val, :old_first)
  elsif (ondicts && word_count > 20) || word_count >= 500 || book_count >= 50
    suggest_root.set(key, val, :old_first) if val[0].split(" ").size < 6
  elsif word_count >= 500
    recycle_root.set(key, val, :old_first)
  end

  next if generic_root.includes?(key)
  combine_root.set(key, val) if word_count >= 1000
end

# # hanviet

puts "\n[Load hanviet]".colorize(:cyan)

hanviet_dicts = {
  "#{OUT_DIR}/core_root/hanviet.dic",
  "#{OUT_DIR}/core_user/hanviet.local.dic",
  "#{INP_DIR}/hanviet/lacviet/words.txt",
  "#{INP_DIR}/hanviet/checked/words.txt",
}
hanviet_dicts.each do |file|
  Cvdict.load!(file).data.each do |key, val|
    generic_root.set(key, val, :old_first)
    EXISTED.add(key)
  end
end

# # cleanup
puts "\n[Cleanup]".colorize(:cyan)

{suggest_root, combine_root, recycle_root}.each do |dic|
  puts "- clean [#{dic.file.colorize(:blue)}]"
  dic.data.each do |key, val|
    if old_val = generic_root.get(key)
      new_val = val - old_val
      if new_val.empty?
        dic.del(key)
      else
        dic.set(key, val, :keep_new)
      end
    end
  end
end

puts "\n[Save result]".colorize(:cyan)

File.write("#{TMP_DIR}/checked.txt", CHECKED.to_a.join("\n"))
File.write("#{TMP_DIR}/existed.txt", EXISTED.to_a.join("\n"))

generic_root.save!
suggest_root.save!
combine_root.save!
recycle_root.save!
