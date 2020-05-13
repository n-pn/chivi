require "json"
require "colorize"
require "file_utils"

require "../src/_utils/string_utils"
require "../src/models/book_info"

input = BookInfo.load_all.values.sort_by(&.tally.-)

tally = [] of Tuple(String, Float64)
score = [] of Tuple(String, Float64)
votes = [] of Tuple(String, Int32)
update = [] of Tuple(String, Int64)
access = [] of Tuple(String, Int64)

wordmap = {
  "zh_titles" => Hash(String, Array(String)).new { |h, k| h[k] = [] of String },
  "hv_titles" => Hash(String, Array(String)).new { |h, k| h[k] = [] of String },
  "vi_titles" => Hash(String, Array(String)).new { |h, k| h[k] = [] of String },

  "zh_authors" => Hash(String, Array(String)).new { |h, k| h[k] = [] of String },
  "vi_authors" => Hash(String, Array(String)).new { |h, k| h[k] = [] of String },
}

def normalize(input : String)
  Utils.unaccent(input.downcase)
end

input.each_with_index do |info, idx|
  next if info.shield > 1
  puts "- <#{idx + 1}> #{info.vi_title}--#{info.vi_author}"

  tally << {info.uuid, info.tally}
  score << {info.uuid, info.score}
  votes << {info.uuid, info.votes}
  update << {info.uuid, info.mftime}
  access << {info.uuid, info.mftime}

  Utils.split_words(info.zh_title).each do |word|
    wordmap["zh_titles"][word] << "#{info.uuid}--#{info.zh_title}"
  end

  Utils.split_words(info.zh_author).each do |word|
    wordmap["zh_authors"][word] << "#{info.uuid}--#{info.zh_author}"
  end

  Utils.split_words(Utils.slugify(info.hv_title)).each do |word|
    next if word =~ /[\p{Han}\p{Hiragana}\p{Katakana}]/
    wordmap["hv_titles"][word] << "#{info.uuid}--#{normalize(info.hv_title)}"
  end

  Utils.split_words(Utils.slugify(info.vi_title)).each do |word|
    next if word =~ /[\p{Han}\p{Hiragana}\p{Katakana}]/
    wordmap["vi_titles"][word] << "#{info.uuid}--#{normalize(info.vi_title)}"
  end

  Utils.split_words(Utils.slugify(info.vi_author)).each do |word|
    next if word =~ /[\p{Han}\p{Hiragana}\p{Katakana}]/
    wordmap["vi_authors"][word] << "#{info.uuid}--#{normalize(info.vi_author)}"
  end
end

puts "- Save indexes...".colorize(:cyan)

INDEX_DIR = "data/indexing"
FileUtils.mkdir_p(INDEX_DIR)

File.write "#{INDEX_DIR}/tally.json", tally.sort_by(&.[1]).to_pretty_json
File.write "#{INDEX_DIR}/score.json", score.sort_by(&.[1]).to_pretty_json
File.write "#{INDEX_DIR}/votes.json", votes.sort_by(&.[1]).to_pretty_json
File.write "#{INDEX_DIR}/update.json", update.sort_by(&.[1]).to_pretty_json
File.write "#{INDEX_DIR}/access.json", access.sort_by(&.[1]).to_pretty_json

WORD_MAPS = {"zh_titles", "zh_authors", "vi_titles", "vi_authors", "hv_titles"}

alias Counter = Hash(String, Int32)
counters = Hash(String, Counter).new

WORD_MAPS.each do |type|
  wordmap_dir = File.join(INDEX_DIR, type)
  FileUtils.rm_rf(wordmap_dir)
  FileUtils.mkdir_p(wordmap_dir)

  counter = Counter.new
  wordmap[type].each do |word, list|
    counter[word] = list.size
    File.write File.join(wordmap_dir, "#{word}.txt"), list.join("\n")
  end

  counters[type] = counter
end

File.write "#{INDEX_DIR}/wordmap.json", counters.to_pretty_json
