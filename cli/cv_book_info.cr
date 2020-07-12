require "json"
require "colorize"
require "file_utils"

require "../src/_utils/text_utils"
require "../src/kernel/book_info"

require "../src/kernel/label_map"
require "../src/kernel/token_map"
require "../src/kernel/value_set"

require "../src/engine"

class ConvertBookInfo
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
      NEW_GENRES.upsert(genre_zh)
      return "Loại khác"
    end

    genre_vi
  end

  SEEDS = {
    "hetushu", "jx_la", "rengshu",
    "xbiquge", "nofff", "duokan8",
    "paoshu8", "69shu", "zhwenpg",
  }

  def seed_order(name : String) : Int32
    SEEDS.index(name) || -1
  end

  getter input : Array(BookInfo)

  def initialize
    @infos = BookInfo.load_all!
    @input = @infos.values.sort_by(&.weight.-)
  end

  HIATUS = Time.utc(2019, 1, 1).to_unix_ms

  def convert!
    @input.each do |info|
      info.title_hv = hanviet(info.title_zh)
      info.title_vi = FIX_TITLES.fetch(info.title_zh, info.title_hv)

      info.title_vi = Utils.titleize(info.title_vi)
      info.author_vi = Utils.titleize(hanviet(info.author_zh))

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

      info.save! # if info.changed?
    end

    NEW_GENRES.save!
  end

  FIX_ZH_TITLES  = LabelMap.load("fix_zh_titles")
  FIX_ZH_AUTHORS = LabelMap.load("fix_zh_authors")

  def resolve_duplicate(old_info, new_info, slug)
    puts old_info.to_json.colorize.cyan
    puts new_info.to_json.colorize.cyan

    old_title = old_info.title_zh
    new_title = new_info.title_zh

    old_author = old_info.author_zh
    new_author = new_info.author_zh

    if old_title != new_title
      puts "\n[ fix title ]".colorize.cyan
      puts "FIX 1 (keep old): `#{new_title}ǁ#{old_title}`"
      puts "FIX 2 (keep new): `#{old_title}ǁ#{new_title}`"
    end

    if old_author != new_author
      puts "\n[ fix author ]".colorize.cyan
      puts "FIX 1 (keep old): `#{new_author}ǁ#{old_author}¦#{new_title}`"
      puts "FIX 2 (keep new): `#{old_author}ǁ#{new_author}¦#{old_title}`"
    end

    print "\nPrompt (1: keep old, 2: keep new, else: skipping): ".colorize.blue

    case gets.try(&.chomp)
    when "1"
      puts "- Keep old!!".colorize.yellow
      File.delete("var/book_infos/#{new_info.uuid}.json")
      FileUtils.rm_rf("var/chap_lists/#{new_info.uuid}")

      if old_title != new_title
        FIX_ZH_TITLES.upsert!(new_title, old_title)
      else
        FIX_ZH_AUTHORS.upsert!(new_author, "#{old_author}¦#{new_title}")
      end
    when "2"
      puts "- Keep new!!".colorize.yellow
      File.delete("var/book_infos/#{old_info.uuid}.json")
      FileUtils.rm_rf("var/chap_lists/#{old_info.uuid}")

      if old_title != new_title
        FIX_ZH_TITLES.upsert!(old_title, new_title)
      else
        FIX_ZH_AUTHORS.upsert!(old_author, "#{new_author}¦#{old_title}")
      end

      FULL_SLUGS[slug] = new_info.uuid
      SLUG_UUIDS.delete(slug)
    else
      puts "- Skipping for now!!"
    end
  end

  FULL_SLUGS = {} of String => String
  SLUG_UUIDS = LabelMap.load("slug_uuid", preload: false)

  def make_slugs!
    @input.each_with_index do |info, idx|
      title_slug = Utils.slugify(info.title_vi, no_accent: true)
      author_slug = Utils.slugify(info.author_vi, no_accent: true)

      full_slug = "#{title_slug}--#{author_slug}"
      if old_uuid = FULL_SLUGS[full_slug]?
        resolve_duplicate(@infos[old_uuid], info, full_slug)
      else
        FULL_SLUGS[full_slug] = info.uuid
      end

      next unless FULL_SLUGS[full_slug] == info.uuid

      if old_uuid = SLUG_UUIDS.fetch(title_slug)
        if old_full_uuid = SLUG_UUIDS.fetch(full_slug)
          raise "DUPLICATE! [#{old_uuid}, #{old_full_uuid}, #{info.uuid}]"
        end

        info.slug = full_slug
      else
        info.slug = title_slug
      end

      SLUG_UUIDS.upsert(info.slug, info.uuid)

      hanviet_slug = Utils.slugify(info.title_hv, no_accent: true)
      if SLUG_UUIDS.has_key?(hanviet_slug)
        full_slug = "#{hanviet_slug}--#{author_slug}"

        unless SLUG_UUIDS.has_key?(full_slug)
          SLUG_UUIDS.upsert(full_slug, info.uuid)
        end
      else
        SLUG_UUIDS.upsert(hanviet_slug, info.uuid)
      end

      next unless info.changed?
      info.save!

      color = info.seed_names.empty? ? :cyan : :blue
      puts "- <#{idx + 1}/#{input.size}> [#{info.slug}] #{info.title_vi}".colorize(color)
    end

    SLUG_UUIDS.save!
  end

  def build_indexes!
    # TODO
  end
end

cmd = ConvertBookInfo.new

cmd.convert! unless ARGV.includes?("index_only")
cmd.make_slugs!
cmd.build_indexes!
