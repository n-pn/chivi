require "json"
require "colorize"
require "file_utils"

require "../../src/engine/cutil"
require "../../src/entity/vbook"

files = Dir.glob("data/txt-out/serials/*.json")
books = files.map { |file| VBook.load(file) }.sort_by(&.tally.-)

# Build indexes

INDEX_DIR = "data/txt-out/indexes"
FileUtils.mkdir_p(INDEX_DIR)

class Query
  include JSON::Serializable

  property title : Array(String)
  property author : Array(String)

  def initialize(book : VBook)
    @title = [
      book.title.zh,
      CUtil.slugify(book.title.vi, no_accent: true),
      CUtil.slugify(book.title.hv, no_accent: true),
    ].uniq

    @author = [
      book.author.zh,
      CUtil.slugify(book.author.vi, no_accent: true),
      CUtil.slugify(book.author.hv, no_accent: true),
    ].uniq
  end
end

query = {} of String => Query
tally = [] of Tuple(String, Float64)
score = [] of Tuple(String, Float64)
votes = [] of Tuple(String, Int32)
update = [] of Tuple(String, Int64)
access = [] of Tuple(String, Int64)

mapping = {} of String => String
missing = [] of String
hastext = [] of String

books.each_with_index do |book, idx|
  label = "- <#{idx + 1}/#{books.size}> [#{book.title.vi}]"

  slug = book.label.us
  query[slug] = Query.new(book)

  mapping[book.label.zh] = book.label.us

  if book.hidden < 2
    tally << {slug, book.tally}
    score << {slug, book.score}
    votes << {slug, book.votes}
    update << {slug, book.mtime}
    access << {slug, book.mtime}
  end

  if book.prefer_site.empty?
    missing << book.label.us
    puts label.colorize(:blue)
  else
    hastext << book.label.us
    puts label.colorize(:green)
  end
end

puts "- MISSING: #{missing.size}"
File.write "data/txt-out/missing.txt", missing.join("\n")

puts "- HASTEXT: #{hastext.size}"
File.write "data/txt-out/hastext.txt", hastext.join("\n")

puts "- MAPPING: #{mapping.size}"
File.write "data/txt-out/mapping.json", mapping.to_pretty_json

puts "- Save indexes...".colorize(:cyan)

File.write "#{INDEX_DIR}/query.json", query.to_pretty_json
File.write "#{INDEX_DIR}/tally.json", tally.sort_by(&.[1].-).to_pretty_json
File.write "#{INDEX_DIR}/score.json", score.sort_by(&.[1].-).to_pretty_json
File.write "#{INDEX_DIR}/votes.json", votes.sort_by(&.[1].-).to_pretty_json
File.write "#{INDEX_DIR}/update.json", update.sort_by(&.[1].-).to_pretty_json
File.write "#{INDEX_DIR}/access.json", access.sort_by(&.[1].-).to_pretty_json
