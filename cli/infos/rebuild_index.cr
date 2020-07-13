require "json"
require "colorize"
require "file_utils"

require "../../src/kernel/book_info"
require "../../src/_utils/text_utils"

books = BookInfo.load_all!

conflicts = Hash(String, Array(String)).new { |h, k| h[k] = [] of String }

has_text = 0
books.each do |book|
  has_text += 1 if book.seed_names.size > 0

  title = book.title_zh.gsub(/\P{Han}/, "")
  author = book.author_zh.gsub(/\P{Han}/, "")
  conflicts["#{title}--#{author}"] << "#{book.title_zh}--#{book.author_zh}"
end

puts "- has_text: #{has_text}".colorize(:yellow)

conflicts.reject! do |key, vals|
  vals.size == 1
end

File.write "tmp/conflicts.json", conflicts.to_pretty_json

# input = BookInfo.load_all.values.sort_by(&.weight.-)

# weight = [] of Tuple(String, Float64)
# rating = [] of Tuple(String, Float64)
# votes = [] of Tuple(String, Float64)
# update = [] of Tuple(String, Float64)
# access = [] of Tuple(String, Float64)

# def mapper
#   Hash(String, Array(String)).new { |h, k| h[k] = [] of String }
# end

# wordmap = {
#   "zh_titles"  => mapper,
#   "hv_titles"  => mapper,
#   "vi_titles"  => mapper,
#   "zh_authors" => mapper,
#   "vi_authors" => mapper,
# }

# def normalize(input : String)
#   Utils.unaccent(input.downcase)
# end

# input.each_with_index do |info, idx|
#   # next if info.shield > 1
#   puts "- <#{idx + 1}> #{info.vi_title}--#{info.vi_author}"

#   weight << {info.ubid, info.weight}
#   rating << {info.ubid, info.rating}
#   update << {info.ubid, info.mftime.to_f}
#   access << {info.ubid, info.weight}

#   Utils.split_words(info.zh_title).each do |word|
#     wordmap["zh_titles"][word] << "#{info.ubid}ǁ#{info.zh_title}ǁ#{info.weight}"
#   end

#   Utils.split_words(info.zh_author).each do |word|
#     wordmap["zh_authors"][word] << "#{info.ubid}ǁ#{info.zh_author}ǁ#{info.weight}"
#   end

#   slug = Utils.slugify(info.hv_title)
#   Utils.split_words(slug).each do |word|
#     next if word =~ /[\p{Han}\p{Hiragana}\p{Katakana}]/
#     wordmap["hv_titles"][word] << "#{info.ubid}ǁ#{slug}ǁ#{info.weight}"
#   end

#   slug = Utils.slugify(info.vi_title)
#   Utils.split_words(slug).each do |word|
#     next if word =~ /[\p{Han}\p{Hiragana}\p{Katakana}]/
#     wordmap["vi_titles"][word] << "#{info.ubid}ǁ#{slug}ǁ#{info.weight}"
#   end

#   slug = Utils.slugify(info.vi_author)
#   Utils.split_words(slug).each do |word|
#     next if word =~ /[\p{Han}\p{Hiragana}\p{Katakana}]/
#     wordmap["vi_authors"][word] << "#{info.ubid}ǁ#{slug}ǁ#{info.weight}"
#   end
# end

# puts "- Save indexes...".colorize(:cyan)

# INDEX_DIR = File.join("var", "appcv", "book_index")
# FileUtils.mkdir_p(INDEX_DIR)

# File.write "#{INDEX_DIR}/weight.json", weight.sort_by(&.[1]).to_pretty_json
# File.write "#{INDEX_DIR}/rating.json", rating.sort_by(&.[1]).to_pretty_json
# File.write "#{INDEX_DIR}/update.json", update.sort_by(&.[1]).to_pretty_json
# File.write "#{INDEX_DIR}/access.json", access.sort_by(&.[1]).to_pretty_json

# WORD_MAPS = {"zh_titles", "zh_authors", "vi_titles", "vi_authors", "hv_titles"}

# alias Counter = Hash(String, Int32)
# counters = Hash(String, Counter).new

# WORD_MAPS.each do |type|
#   wordmap_dir = File.join(INDEX_DIR, type)
#   FileUtils.rm_rf(wordmap_dir)
#   FileUtils.mkdir_p(wordmap_dir)

#   counter = Counter.new
#   wordmap[type].each do |word, list|
#     counter[word] = list.size
#     File.write File.join(wordmap_dir, "#{word}.txt"), list.join("\n")
#   end

#   counters[type] = counter
# end

# File.write "#{INDEX_DIR}/wordmap.json", counters.to_pretty_json
