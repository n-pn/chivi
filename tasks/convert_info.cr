require "json"
require "colorize"
require "file_utils"

require "../src/_utils/string_utils"
require "../src/engine"
require "../src/models/book_info"

def hanviet(input : String)
  return input unless input =~ /\p{Han}/
  Engine.hanviet(input, apply_cap: true).vi_text
end

MAP_DIR = File.join("tasks", "books", "maps")

TITLE_FILE = File.join(MAP_DIR, "titles.json")
MAP_TITLES = Hash(String, Array(String)).from_json(File.read(TITLE_FILE))

def map_title(zh_title)
  if vi_titles = MAP_TITLES[zh_title]?
    vi_titles.first
  end
end

GENRE_FILE = File.join(MAP_DIR, "genres.json")
MAP_GENRES = Hash(String, Tuple(String, Bool)).from_json(File.read(GENRE_FILE))

NEW_GENRES = Set(String).new

def map_genre(zh_genre : String)
  return {"Loại khác", false} if zh_genre.empty?

  if res = MAP_GENRES[zh_genre]?
    return res
  end

  NEW_GENRES.add(zh_genre)
  {"Loại khác", true}
end

TAKEN_SLUGS = Set(String).new

def pick_slug(title_slug, author_slug)
  unless title_slug.size < 5 || TAKEN_SLUGS.includes?(title_slug)
    return title_slug
  end

  full_slug = "#{title_slug}--#{author_slug}"
  raise "DUPLICATE: #{full_slug}" if TAKEN_SLUGS.includes?(full_slug)

  full_slug
end

def translate(input : String)
  return input if input.empty?
  lines = input.split("\n")
  Engine.translate(lines, :plain, nil, "local").join("\n")
end

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

def zh_split(str : String)
  return [str] unless str =~ /\p{Han}/
  str.split("")
end

def tokenize(info)
  chars = zh_split(info.zh_title)
  chars.concat(zh_split(info.zh_author))

  hv_slug = Utils.slugify(info.hv_title, no_accent: true)
  chars.concat(hv_slug.split("-"))

  chars.concat(info.title_slug.split("-"))
  chars.concat(info.author_slug.split("-"))

  chars.uniq
end

input.each_with_index do |info, idx|
  info.hv_title = hanviet(info.zh_title)

  info.vi_title = map_title(info.zh_title) || info.hv_title
  info.title_slug = Utils.slugify(info.vi_title, no_accent: true)

  info.vi_author = Utils.titleize(hanviet(info.zh_author))
  info.author_slug = Utils.slugify(info.vi_author, no_accent: true)

  info.slug = pick_slug(info.title_slug, info.author_slug)
  TAKEN_SLUGS.add(info.slug)

  info.vi_genre, move_to_tag = map_genre(info.zh_genre)
  info.genre_slug = Utils.slugify(info.vi_genre, no_accent: true)

  if move_to_tag && !info.zh_tags.includes?(info.zh_genre)
    info.zh_tags << info.zh_genre
    info.vi_tags << ""
  end

  info.zh_tags.each_with_index do |tag, idx|
    info.vi_tags[idx] = hanviet(tag)
  end

  info.vi_intro = translate(info.zh_intro)

  BookInfo.save!(info)

  mapping[info.slug] = info.uuid

  if info.shield < 2
    tally << {info.uuid, info.tally}
    score << {info.uuid, info.score}
    votes << {info.uuid, info.votes}
    update << {info.uuid, info.mftime}
    access << {info.uuid, info.mftime}

    tokenize(info).each do |token|
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

File.write("tasks/books/maps/new-genres.txt", NEW_GENRES.join("\n"))

puts "- Save indexes...".colorize(:cyan)

INDEX_DIR = "data/indexing"
FileUtils.mkdir_p(INDEX_DIR)

File.write "#{INDEX_DIR}/query.json", query.to_pretty_json
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
