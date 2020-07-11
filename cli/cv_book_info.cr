require "json"
require "colorize"
require "file_utils"

require "../src/_utils/text_utils"
require "../src/kernel/book_info"
require "../src/engine"

def hanviet(input : String)
  return input unless input =~ /\p{Han}/
  Engine.hanviet(input, apply_cap: true).vi_text
end

MAP_DIR = File.join("etc", "bookdb")

TITLE_FILE = File.join(MAP_DIR, "map-titles.json")
MAP_TITLES = Hash(String, Array(String)).from_json(File.read(TITLE_FILE))

def map_title(title_zh : String)
  if title_vis = MAP_TITLES[title_zh]?
    title_vis.first
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

def pick_slug(title_slug : String, author_slug : String) : String
  unless title_slug.size < 5 || TAKEN_SLUGS.includes?(title_slug)
    return title_slug
  end

  full_slug = "#{title_slug}--#{author_slug}"
  raise "DUPLICATE: #{full_slug}" if TAKEN_SLUGS.includes?(full_slug)

  full_slug
end

SEEDS = {
  "hetushu", "jx_la", "rengshu",
  "xbiquge", "nofff", "duokan8",
  "paoshu8", "69shu", "zhwenpg",
}

def seed_order(name : String) : Int32
  SEEDS.index(name) || -1
end

def translate(input : String, book : String) : String
  return input if input.empty?
  lines = input.split("\n")
  Engine.cv_plain(lines, book).map(&.vi_text).join("\n")
end

input = BookInfo.load_all!.values.sort_by(&.weight.-)

mapping = {} of String => String
missing = [] of String
hastext = [] of String

HIATUS = Time.utc(2019, 1, 1).to_unix_ms

input.each_with_index do |info, idx|
  info.title_hv = hanviet(info.title_zh)
  info.title_vi = map_title(info.title_zh) || info.title_hv

  info.author_vi = Utils.titleize(hanviet(info.author_zh))

  title_slug = Utils.slugify(info.title_vi, no_accent: true)
  author_slug = Utils.slugify(info.author_vi, no_accent: true)

  info.slug = pick_slug(title_slug, author_slug)
  TAKEN_SLUGS.add(info.slug)

  info.genre_vi, _ = map_genre(info.genre_zh)

  info.tags_zh.each_with_index do |tag, idx|
    info.tags_vi[idx] = hanviet(tag)
  end

  info.intro_vi = translate(info.intro_zh, info.uuid)

  if info.status == 0 && info.mftime < HIATUS
    info.status = 3
  end

  info.seed_names.sort_by! { |seed| seed_order(seed) }

  info.seed_infos.each_value do |seed|
    chap = seed.latest

    label_zh = CvData.zh_text(chap.label)
    label_cv = Engine.hanviet(label_zh)
    chap.label = label_cv.to_s

    title_zh = CvData.zh_text(chap.title)
    title_cv = Engine.cv_plain(title_zh, info.uuid)

    chap.title = title_cv.to_s
    chap.set_slug(title_cv.vi_text)
  end

  info.save!

  mapping[info.slug] = info.uuid

  # mapping[info.title_zh] ||= info.uuid

  hanviet_slug = Utils.slugify(info.title_hv, no_accent: true)
  if mapping.has_key?(hanviet_slug)
    mapping["#{hanviet_slug}--#{author_slug}"] ||= info.uuid
  else
    mapping[hanviet_slug] ||= info.uuid
  end

  label = "- <#{idx + 1}/#{input.size}> [#{info.slug}] #{info.title_vi}"
  if info.seed_names.empty?
    missing << info.uuid
    puts label.colorize(:blue)
  else
    hastext << info.uuid
    puts label.colorize(:green)
  end
end

File.write("var/new-genres.txt", NEW_GENRES.join("\n"))

INDEX_DIR = "var/.indexes"
FileUtils.mkdir_p(INDEX_DIR)

puts "-- missing: #{missing.size}"
File.write "#{INDEX_DIR}/missing.txt", missing.join("\n")

puts "-- hastext: #{hastext.size}"
File.write "#{INDEX_DIR}/hastext.txt", hastext.join("\n")

puts "-- mapping: #{mapping.size}"
File.write "#{INDEX_DIR}/mapping.json", mapping.to_pretty_json
