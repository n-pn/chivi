require "json"
require "colorize"
require "file_utils"

require "./models/my_book"
require "../../src/engine/cutil"

INDEX_DIR = "data/txt-out/indexes"
FileUtils.mkdir_p(INDEX_DIR)

# Build indexes

class Query
  include JSON::Serializable

  property title : Array(String)
  property author : Array(String)

  def initialize(book : MyBook)
    @title = [
      book.zh_title,
      CUtil.slugify(book.vi_title, no_accent: true),
      CUtil.slugify(MyUtil.hanviet(book.zh_title), no_accent: true),
    ].uniq

    @author = [
      book.zh_author,
      CUtil.slugify(book.vi_author, no_accent: true),
      # CUtil.slugify(MyUtil.hanviet(book.zh_author), no_accent: true),
    ] # .uniq
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

files = Dir.glob("data/txt-out/serials/*.json")
books = files.map { |file| MyBook.from_json(File.read(file)) }
books = books.sort_by(&.tally.-)

books.each_with_index do |book, idx|
  label = "- <#{idx + 1}/#{books.size}> [#{book.vi_title}]"

  slug = book.vi_slug
  query[slug] = Query.new(book)

  mapping[book.zh_slug] = book.vi_slug

  if book.prefer_site.empty?
    missing << book.vi_slug
    puts label.colorize(:blue)
  else
    hastext << book.vi_slug
    puts label.colorize(:green)

    tally << {slug, book.tally}
    score << {slug, book.score}
    votes << {slug, book.votes}
    update << {slug, book.updated_at}
    access << {slug, book.updated_at}
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
