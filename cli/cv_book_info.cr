require "json"
require "colorize"
require "file_utils"

require "../src/_utils/text_utils"
require "../src/kernel/book_info"

require "../src/kernel/label_map"
require "../src/kernel/token_map"
require "../src/kernel/value_set"

require "../src/engine"

module Convert
  extend self

  def hanviet(input : String)
    return input unless input =~ /\p{Han}/
    Engine.hanviet(input, apply_cap: true).vi_text
  end

  def cv_intro(input : String, dname : String) : String
    lines = input.split("\n")
    Engine.cv_plain(lines, dname).map(&.vi_text).join("\n")
  end

  def cv_title(input : String, dname : String) : String
    Engine.cv_plain(input, dname)
  end

  FIX_TITLES = LabelMap.load("fix_vi_titles")
  FIX_GENRES = LabelMap.load("fix_vi_genres")
  NEW_GENRES = ValueSet.load("unknown_genres")

  def map_genre(genre_zh : String)
    unless genre_vi = FIX_GENRES.fetch(genre_zh)
      NEW_GENRES.add(genre_zh)
      return "Loại khác"
    end

    genre_vi
  end

  SLUG_UUIDS = LabelMap.load("slug_uuid", preload: false)

  SEEDS = {
    "hetushu", "jx_la", "rengshu",
    "xbiquge", "nofff", "duokan8",
    "paoshu8", "69shu", "zhwenpg",
  }

  def seed_order(name : String) : Int32
    SEEDS.index(name) || -1
  end

  HIATUS = Time.utc(2019, 1, 1).to_unix_ms

  def run!
    infos = BookInfo.load_all!
    input = infos.values.sort_by(&.weight.-)

    input.each_with_index do |info, idx|
      info.title_hv = hanviet(info.title_zh)
      info.title_vi = FIX_TITLES.fetch(info.title_zh, info.title_hv)

      info.title_vi = Utils.titleize(info.title_vi)
      title_sl = Utils.slugify(info.title_vi, no_accent: true)

      info.author_vi = Utils.titleize(hanviet(info.author_zh))
      author_sl = Utils.slugify(info.author_vi, no_accent: true)

      unless title_sl.size < 5 || SLUG_UUIDS.fetch(title_sl)
        info.slug = title_sl
        SLUG_UUIDS.upsert(title_sl, info.uuid)
      else
        full_slug = "#{title_sl}--#{author_sl}"

        if old_uuid = SLUG_UUIDS.fetch(full_slug)
          puts infos[old_uuid].to_pretty_json
          puts info.to_pretty_json
          raise "DUPLICATE!!"
        end
      end

      hanviet_sl = Utils.slugify(info.title_hv, no_accent: true)
      if SLUG_UUIDS.has_key?(hanviet_sl)
        hanviet_full_sl = "#{hanviet_sl}--#{author_sl}"
        unless SLUG_UUIDS.has_key?(hanviet_full_sl)
          SLUG_UUIDS.upsert(hanviet_full_sl, info.uuid)
        end
      else
        SLUG_UUIDS.upsert(hanviet_sl, info.uuid)
      end

      info.genre_vi = map_genre(info.genre_zh)

      info.tags_zh.each_with_index do |tag, idx|
        info.tags_vi[idx] = hanviet(tag)
      end

      info.intro_vi = cv_intro(info.intro_zh, info.uuid)

      if info.status == 0 && info.mftime < HIATUS
        info.status = 3
      end

      info.seed_names.sort_by! { |seed| seed_order(seed) }

      info.seed_infos.each_value do |seed|
        chap = seed.latest
        chap.label_vi = Engine.cv_plain(chap.label_zh, info.uuid).vi_text
        chap.title_vi = Engine.cv_plain(chap.title_zh, info.uuid).vi_text
        chap.set_slug(chap.title_vi)
      end

      info.save!

      color = info.seed_names.empty? ? :cyan : :blue
      puts "- <#{idx + 1}/#{input.size}> [#{info.slug}] #{info.title_vi}".colorize(color)
    end
  end

  def save!
    SLUG_UUIDS.save!
    NEW_GENRES.save!
  end
end

Convert.run!

# File.write("var/new-genres.txt", NEW_GENRES.join("\n"))

# INDEX_DIR = "var/.indexes"
# FileUtils.mkdir_p(INDEX_DIR)

# puts "-- missing: #{missing.size}"
# File.write "#{INDEX_DIR}/missing.txt", missing.join("\n")

# puts "-- hastext: #{hastext.size}"
# File.write "#{INDEX_DIR}/hastext.txt", hastext.join("\n")

# puts "-- mapping: #{mapping.size}"
# File.write "#{INDEX_DIR}/mapping.json", mapping.to_pretty_json
