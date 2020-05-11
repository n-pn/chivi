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

mapping = {} of String => String
missing = [] of String
hastext = [] of String

query = Hash(String, Array(String)).new { |h, k| h[k] = [] of String }

def gen_query_words(info)
  chars = Utils.split_words(info.zh_title)
  chars.concat(Utils.split_words(info.zh_author))
  chars.concat(Utils.split_words(info.hv_title))
  chars.concat(info.title_slug.split("-").reject(&.empty?))
  chars.concat(info.author_slug.split("-").reject(&.empty?))

  chars.uniq
end

input.each_with_index do |info, idx|
  mapping[info.slug] = info.uuid

  if info.shield < 2
    tally << {info.uuid, info.tally}
    score << {info.uuid, info.score}
    votes << {info.uuid, info.votes}
    update << {info.uuid, info.mftime}
    access << {info.uuid, info.mftime}

    gen_query_words(info).each do |token|
      query[token] << info.uuid
    end
  end

  label = "- <#{idx + 1}/#{input.size}> [#{info.slug}] #{info.vi_title}"
  if info.cr_site_df.empty?
    missing << info.uuid
    puts label.colorize(:blue)
  else
    hastext << info.uuid
    puts label.colorize(:green)
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

puts "-- missing: #{missing.size}"
File.write "#{INDEX_DIR}/missing.txt", missing.join("\n")

puts "-- hastext: #{hastext.size}"
File.write "#{INDEX_DIR}/hastext.txt", hastext.join("\n")

puts "-- mapping: #{mapping.size}"
File.write "#{INDEX_DIR}/mapping.json", mapping.to_pretty_json

File.write "#{INDEX_DIR}/query.json", query.to_pretty_json

QUERY_DIR = File.join(INDEX_DIR, "queries")
FileUtils.rm_rf(QUERY_DIR)
FileUtils.mkdir_p(QUERY_DIR)

query.each do |word, list|
  File.write File.join(QUERY_DIR, "#{word}.txt"), list.join("\n")
end
