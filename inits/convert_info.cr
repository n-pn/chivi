require "json"
require "colorize"
require "file_utils"

require "../src/engine"
require "../src/models/vp_info"

def hanviet(input : String)
  return input unless input =~ /\p{Han}/
  Engine.hanviet(input, apply_cap: true).vi_text
end

MAP_DIR = File.join("inits", "books", "mapping")

TITLE_FILE = File.join(MAP_DIR, "map-titles.json")
MAP_TITLES = Hash(String, Array(String)).from_json(File.read(TITLE_FILE))

def map_title(zh_title)
  if vi_titles = MAP_TITLES[zh_title]?
    vi_titles.first
  end
end

GENRE_FILE = File.join(MAP_DIR, "map-genres.json")
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

def fix_genre(genre : String)
  return genre if genre == "轻小说"
  genre.sub("小说", "")
end

def translate(input : String)
  return input if input.empty?
  lines = input.split("\n")
  Engine.translate(lines, :plain, nil, "local").join("\n")
end

input = VpInfo.load_all.values.sort_by(&.tally.-)

tally = [] of Tuple(String, Float64)
score = [] of Tuple(String, Float64)
votes = [] of Tuple(String, Int32)
update = [] of Tuple(String, Int64)
access = [] of Tuple(String, Int64)

mapping = {} of String => String
missing = [] of String
hastext = [] of String

query = Hash(String, Array(String)).new { |h, k| h[k] = [] of String }

def split_zh(str : String)
  return [str] unless str =~ /\p{Han}/
  str.split("")
end

def tokenize(info)
  chars = split_zh(info.title_zh)
  chars.concat(split_zh(info.author_zh))

  chars.concat(info.title_hv_slug.split("-"))
  chars.concat(info.title_vi_slug.split("-"))
  chars.concat(info.author_vi_slug.split("-"))

  chars.uniq
end

input.each_with_index do |info, idx|
  info.title_hv = hanviet(info.title_zh)
  info.title_hv_slug = CvUtil.slugify(info.title_vi, no_accent: true)

  info.title_vi = map_title(info.title_zh) || info.title_hv
  info.title_vi_slug = CvUtil.slugify(info.title_vi, no_accent: true)

  info.author_vi = CvUtil.titleize(hanviet(info.author_zh))
  info.author_vi_slug = CvUtil.slugify(info.author_vi, no_accent: true)

  info.slug = pick_slug(info.title_vi_slug, info.author_vi_slug)
  TAKEN_SLUGS.add(info.slug)

  info.genre_zh = fix_genre(info.genre_zh)
  info.genre_vi, move_to_tag = map_genre(info.genre_zh)

  info.genre_vi_slug = CvUtil.slugify(info.genre_vi, no_accent: true)
  info.tags_zh.push(info.genre_zh).uniq! if move_to_tag

  info.tags_vi.clear
  info.tags_zh.each { |tag| info.tags_vi << hanviet(tag) }

  info.intro_vi = translate(info.intro_zh)

  VpInfo.save_json(info)

  mapping[info.slug] = info.uuid

  if info.shield < 2
    tally << {info.uuid, info.tally}
    score << {info.uuid, info.score}
    votes << {info.uuid, info.votes}
    update << {info.uuid, info.update}
    access << {info.uuid, info.update}

    tokenize(info).each do |token|
      query[token] << info.uuid
    end
  end

  label = "- <#{idx + 1}/#{input.size}> [#{info.slug}] #{info.title_vi}"
  if info.cr_site_df.empty?
    missing << info.uuid
    puts label.colorize(:blue)
  else
    hastext << info.uuid
    puts label.colorize(:green)
  end
end

File.write("inits/genres.txt", NEW_GENRES.join("\n"))

puts "- Save indexes...".colorize(:cyan)

INDEX_DIR = "data/indexes"
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
