# combine extraqt and localqt
require "json"

require "chivi/util"
require "./util/cvdict"

puts "- [load deps]".colorize(:cyan)

alias Counter = Hash(String, Int32)

COUNT_WORDS = Counter.from_json File.read(".inp/counter/words.json")
COUNT_BOOKS = Counter.from_json File.read(".inp/counter/books.json")

ONDICTS = Set(String).new File.read_lines(".inp/ondicts.txt")

puts "- [load history]".colorize(:cyan)

CHECKED = Set(String).new
EXISTED = Set(String).new

Dir.glob(".inp/localqt/*.log") do |file|
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
  puts "FILE: #{file}".colorize(:blue)

  File.read_lines(file).compact_map do |line|
    begin
      key, val = line.split "=", 2
      {Chivi::Util.normalize(key).join, split_val(val)}
    rescue
      nil
    end
  end
end

puts "[Read localqt]".colorize(:cyan)

INPUT = Hash(String, Set(String)).new { |h, k| h[k] = Set(String).new }
# WORDS = Dict.new { |h, k| h[k] = Set(String).new }

Dir.glob(".inp/localqt/*.txt") do |file|
  puts "- load file: [#{file.colorize(:cyan)}]"

  read_file(file).each do |key, vals|
    EXISTED.add key.as(String)
    next if should_skip?(key)
    INPUT[key].concat(vals) unless vals.empty?
  end
end

# replace localqt with manually checked
Dir.glob(".inp/localqt/replace/*.txt") do |file|
  puts "- load file: [#{file.colorize(:blue)}]"

  read_file(file).each do |key, vals|
    CHECKED.add(key)
    EXISTED.add(key)
    INPUT[key].clear.concat(vals)
  end
end

puts "[extract localqt]".colorize(:cyan)

generic_base = Cvdict.new(".dic/common/generic.dic")
generic_local = Cvdict.new(".dic/common/generic.local.fix")
generic_extra = Cvdict.new(".dic/common/generic.extra.fix")

suggest_base = Cvdict.new(".dic/common/suggest.dic")
suggest_local = Cvdict.new(".dic/common/suggest.local.fix")
suggest_extra = Cvdict.new(".dic/common/suggest.extra.fix")

combine_base = Cvdict.new(".dic/common/combine.dic")
combine_local = Cvdict.new(".dic/common/combine.local.fix")
combine_extra = Cvdict.new(".dic/common/combine.extra.fix")

# load hanviet
generic_base.merge!(".dic/hanviet.dic")
generic_base.merge!(".inp/hanviet/lacviet/words.txt")
generic_base.merge!(".inp/hanviet/trichdan/words.txt")

# load localvp

INPUT.each do |key, vals|
  book_count = COUNT_BOOKS[key]? || 0
  word_count = COUNT_WORDS[key]? || 0

  checked = CHECKED.includes?(key)
  ondicts = ONDICTS.includes?(key)

  words, names = vals.partition { |x| x == x.downcase }
  words = words.first(4)
  names = names.first(4)

  unless words.empty?
    if (ondicts || word_count >= 50) && (checked || book_count >= 10)
      if ondicts || checked || book_count >= 20
        generic_base.set(key, words, :keep_new)
      else
        generic_local.set(key, words, :keep_new)
      end
    elsif checked || ondicts
      suggest_base.set(key, words, :keep_new)
    elsif word_count >= 10
      suggest_local.set(key, words, :keep_new)
    else
      suggest_extra.set(key, words, :keep_new)
    end
  end

  unless names.empty?
    if (ondicts || word_count >= 100) && book_count >= 10 && words.empty?
      if ondicts || checked || book_count >= 20
        generic_base.set(key, names, :new_first)
      else
        generic_local.set(key, names, :new_first)
      end
    elsif checked || ondicts || book_count >= 5
      suggest_base.set(key, names, :new_first)
    elsif word_count >= 10
      suggest_local.set(key, names, :new_first)
    else
      suggest_extra.set(key, names, :new_first)
    end

    # next if key =~ /^\P{Han}/ || generic.includes?(key)
    if checked
      combine_base.set(key, names, :new_first)
    elsif key !~ /^\P{Han}/
      combine_local.set(key, names, :new_first)
    elsif word_count >= 10
      combine_extra.set(key, names, :new_first)
    end
  end
end

puts "[Load extraqt]".colorize(:cyan)

Cvdict.load!(".inp/extraqt/words.txt").data.each do |key, val|
  next if CHECKED.includes?(key)

  book_count = COUNT_BOOKS[key]? || 0
  word_count = COUNT_WORDS[key]? || 0

  ondicts = ONDICTS.includes?(key)
  existed = EXISTED.includes?(key)

  if (ondicts || word_count >= 1000) && book_count >= 100
    if ondicts && !existed && book_count >= 200
      generic_base.set(key, val)
    elsif ondicts && word_count >= 1000
      generic_local.set(key, val)
    else
      generic_extra.set(key, val)
    end
  elsif ondicts || book_count >= 100
    suggest_base.set(key, val)
  elsif word_count >= 5000 && !existed
    suggest_local.set(key, val)
  elsif word_count >= 1000
    suggest_extra.set(key, val)
  end
end

Cvdict.load!(".inp/extraqt/names.txt").data.each do |key, val|
  next if CHECKED.includes?(key)

  book_count = COUNT_BOOKS[key]? || 0
  word_count = COUNT_WORDS[key]? || 0

  ondicts = ONDICTS.includes?(key)
  existed = EXISTED.includes?(key)

  if (ondicts || word_count >= 1000) && book_count >= 100
    if ondicts && !existed && book_count >= 200
      generic_base.set(key, val)
    elsif ondicts && word_count >= 1000
      generic_local.set(key, val)
    else
      generic_extra.set(key, val)
    end
  elsif ondicts || book_count >= 100 && word_count >= 1000
    suggest_base.set(key, val)
  elsif word_count >= 5000 && !existed
    suggest_local.set(key, val)
  elsif word_count >= 1000
    suggest_extra.set(key, val)
  end

  if word_count >= 1000 && !existed
    if book_count >= 50
      combine_local.set(key, val)
    else
      combine_extra.set(key, val)
    end
  end
end

Dir.glob(".inp/persist/generic/**/*.txt").each do |file|
  Cvdict.load!(file).data.each do |key, val|
    book_count = COUNT_BOOKS[key]? || 0
    ondicts = ONDICTS.includes?(key)

    if ondicts || book_count >= 20
      generic_base.set(key, val)
    else
      generic_local.set(key, val)
    end
  end
end

Dir.glob(".inp/persist/suggest/**/*.txt").each do |file|
  Cvdict.load!(file).data.each do |key, val|
    book_count = COUNT_BOOKS[key]? || 0
    ondicts = ONDICTS.includes?(key)

    if ondicts || book_count >= 20
      suggest_base.set(key, val)
    else
      suggest_local.set(key, val)
    end
  end
end

# # cleanup

{suggest_base, suggest_local, suggest_extra}.each do |suggest|
  suggest.data.each do |key, val|
    if old_val = generic_base.get(key) || generic_local.get(key)
      new_val = val - old_val
      if new_val.empty?
        suggest.del(key)
      else
        suggest.set(key, val, :keep_new)
      end
    end
  end
end

File.write(".tmp/checked.txt", CHECKED.to_a.join("\n"))

generic_base.save!
generic_local.save!
generic_extra.save!

suggest_base.save!
suggest_local.save!
suggest_extra.save!

combine_base.save!
combine_local.save!
combine_extra.save!
