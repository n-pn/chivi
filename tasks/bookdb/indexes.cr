require "json"
require "colorize"
require "file_utils"

require "./models/my_book"
require "../../src/engine/cutil"

INDEX_DIR = "data/txt-out/serials/indexes"
FileUtils.mkdir_p(INDEX_DIR)

# Build indexes

class Mapping
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

slugs = {} of String => String
mapping = {} of String => Mapping
missing = [] of String
hastext = [] of String

tally = [] of Tuple(String, Float64)
score = [] of Tuple(String, Float64)
votes = [] of Tuple(String, Int32)
update = [] of Tuple(String, Int64)
access = [] of Tuple(String, Int64)

files = Dir.glob("data/txt-out/serials/*.json")
books = files.map { |file| MyBook.from_json(File.read(file)) }
books = books.sort_by(&.tally.-)

books.each_with_index do |book, idx|
  slug = book.vi_slug
  label = "- <#{idx + 1}/#{books.size}> [#{slug}]"

  slugs[book.zh_slug] = slug
  mapping[book.vi_slug] = Mapping.new(book)

  tally << {slug, book.tally}
  score << {slug, book.score}
  votes << {slug, book.votes}
  update << {slug, book.updated_at}
  access << {slug, book.updated_at}

  if book.prefer_site.empty?
    puts label.colorize(:blue)
    missing << slug
  else
    puts label.colorize(:green)
    hastext << slug
  end
end

puts "- Save indexes...".colorize(:cyan)

File.write "data/txt-out/slugs.json", slugs.to_pretty_json

File.write "#{INDEX_DIR}/mapping.json", mapping.to_pretty_json

File.write "#{INDEX_DIR}/access.json", access.sort_by(&.[1].-).to_pretty_json
File.write "#{INDEX_DIR}/update.json", update.sort_by(&.[1].-).to_pretty_json
File.write "#{INDEX_DIR}/score.json", score.sort_by(&.[1].-).to_pretty_json
File.write "#{INDEX_DIR}/votes.json", votes.sort_by(&.[1].-).to_pretty_json
File.write "#{INDEX_DIR}/tally.json", tally.sort_by(&.[1].-).to_pretty_json

puts "- MISSING: #{missing.size}"
File.write "#{INDEX_DIR}/missing.txt", missing.join("\n")

puts "- HASTEXT: #{hastext.size}"
File.write "#{INDEX_DIR}/hastext.txt", hastext.join("\n")
