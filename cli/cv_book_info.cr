require "json"
require "colorize"
require "file_utils"

require "../src/_utils/text_utils"
require "../src/kernel/book_info"

require "../src/kernel/label_map"
require "../src/kernel/token_map"
require "../src/kernel/value_set"
require "../src/kernel/order_set"

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

  getter input : Array(BookInfo)

  def initialize
    @infos = BookInfo.load_all!
    @input = @infos.values.sort_by(&.weight.-)
  end

  HIATUS = Time.utc(2019, 1, 1).to_unix_ms
  TITLES = LabelMap.load("fix_vi_titles")

  def convert!
    @input.each do |info|
      info.title_hv = hanviet(info.title_zh)
      info.title_vi = TITLES.fetch(info.title_zh, info.title_hv)

      info.title_vi = Utils.titleize(info.title_vi)
      info.author_vi = Utils.titleize(hanviet(info.author_zh))

      map_genres(info)

      info.tags_zh.each_with_index do |tag, idx|
        tag_vi = map_genre(tag) || Engine.cv_plain(tag, "tonghop").vi_text
        info.tags_vi[idx] = tag_vi
      end

      info.intro_vi = cv_intro(info.intro_zh, info.uuid)
      if info.status == 0 && info.mftime < HIATUS
        info.status = 3
      end

      info.seed_names.sort_by! { |seed| seed_order(seed) }

      info.seed_infos.each_value do |seed|
        chap = seed.latest
        chap.label_vi = Engine.cv_title(chap.label_zh, info.uuid).vi_text
        chap.title_vi = Engine.cv_title(chap.title_zh, info.uuid).vi_text
        chap.set_slug(chap.title_vi)
      end

      info.save! # if info.changed?
    end
  end

  def map_genre(genre)
    case genre
    when "玄幻"  then "Huyền ảo"
    when "奇幻"  then "Kỳ huyễn"
    when "幻想"  then "Giả tưởng"
    when "魔法"  then "Ma pháp"
    when "历史"  then "Lịch sử"
    when "军事"  then "Quân sự"
    when "都市"  then "Đô thị"
    when "现实"  then "Hiện thực"
    when "职场"  then "Chức trường"
    when "官场"  then "Quan trường"
    when "校园"  then "Vườn trường"
    when "商战"  then "Thương chiến"
    when "仙侠"  then "Tiên hiệp"
    when "修真"  then "Tu chân"
    when "科幻"  then "Khoa viễn"
    when "空间"  then "Không gian"
    when "游戏"  then "Trò chơi"
    when "体育"  then "Thể thao"
    when "竞技"  then "Thi đấu"
    when "悬疑"  then "Huyền nghi"
    when "惊悚"  then "Kinh dị"
    when "灵异"  then "Thần quái"
    when "同人"  then "Đồng nhân"
    when "武侠"  then "Võ hiệp"
    when "耽美"  then "Đam mỹ"
    when "女生"  then "Nữ sinh"
    when "言情"  then "Ngôn tình"
    when "穿越"  then "Xuyên việt"
    when "二次元" then "Nhị thứ nguyên"
    when "轻小说" then "Khinh tiểu thuyết"
    end
  end

  def add_genre(info, *genres : String) : Void
    genres.each do |genre|
      info.add_genre(genre, map_genre(genre).not_nil!)
    end
  end

  def map_genres(info)
    # TODO: fix the clusterfuck code, check for changing of code

    genres_zh = [] of String
    genres_vi = [] of String

    if info.genres_zh.empty?
      info.add_genre("其他", "Loại khác")
      return info
    end

    input = info.genres_zh.dup

    info.genres_zh.clear
    info.genres_vi.clear

    input.each do |genre_zh|
      if genre_vi = map_genre(genre_zh)
        info.add_genre(genre_zh, genre_vi)
        next
      end

      case genre_zh
      when "都市言情"
        add_genre(info, "都市", "言情")
      when "科幻空间"
        add_genre(info, "科幻", "空间")
      when "科幻灵异"
        add_genre(info, "科幻", "灵异")
      when "游戏竞技", "网游竞技"
        add_genre(info, "游戏", "竞技")
      when "武侠仙侠"
        add_genre(info, "武侠", "仙侠")
      when "修真武侠"
        add_genre(info, "修真", "武侠")
      when "历史军事"
        add_genre(info, "历史", "军事")
      when "幻想言情"
        add_genre(info, "幻想", "言情")
      when "悬疑惊悚"
        add_genre(info, "悬疑", "惊悚")
      when "玄幻魔法"
        add_genre(info, "幻想", "魔法")
      when "玄幻奇幻"
        add_genre(info, "玄幻", "奇幻")
      when "奇幻修真"
        add_genre(info, "奇幻", "修真")
      when "架空历史"
        add_genre(info, "幻想", "历史")
      when "官场职场"
        add_genre(info, "官场", "职场")
      when "总裁豪门"
        add_genre(info, "都市", "言情")
      when "衍生同人", "小说同人"
        add_genre(info, "同人")
      when "女生频道"
        add_genre(info, "女生")
      when "耽美纯爱"
        add_genre(info, "耽美", "女生")
      when "青春校园"
        add_genre(info, "校园", "都市")
      when "悬疑推理"
        add_genre(info, "悬疑")
      when "仙侠奇缘", "经典仙侠"
        add_genre(info, "仙侠")
      when "穿越时空"
        add_genre(info, "穿越")
      when "网游"
        add_genre(info, "游戏")
      when "其他", "综合其他"
        if info.genres_zh.size < 2
          info.add_genre("其他", "Loại khác")
        end
      else
        info.add_genre(genre_zh, hanviet(genre_zh))
      end
    end
  end

  SEEDS = {
    "hetushu", "jx_la", "rengshu",
    "xbiquge", "nofff", "duokan8",
    "paoshu8", "69shu", "zhwenpg",
  }

  def seed_order(name : String) : Int32
    SEEDS.index(name) || -1
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
  SLUG_UUIDS = LabelMap.load("slug--uuid", preload: false)

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
    book_rating = OrderMap.load("uuid--rating")
    book_weight = OrderMap.load("uuid--weight")
    book_update = OrderMap.load("uuid--update")
    book_access = OrderMap.load("uuid--access")

    title_zh_map = TokenMap.load("uuid--title_zh", preload: false)
    title_vi_map = TokenMap.load("uuid--title_vi", preload: false)
    title_hv_map = TokenMap.load("uuid--title_hv", preload: false)

    author_zh_map = TokenMap.load("uuid--author_zh", preload: false)
    author_vi_map = TokenMap.load("uuid--author_vi", preload: false)

    genres_vi_map = TokenMap.load("uuid--genres_vi", preload: false)
    tags_vi_map = TokenMap.load("uuid--tags_vi", preload: false)

    @input.each do |info|
      uuid = info.uuid

      book_rating.upsert(uuid, info.scored)
      book_weight.upsert(uuid, info.weight)
      book_update.upsert(uuid, info.mftime)
      book_access.upsert(uuid, info.mftime)

      title_zh_map.upsert(uuid, Utils.split_words(info.title_zh))
      title_vi_map.upsert(uuid, Utils.split_words(info.title_vi))
      title_hv_map.upsert(uuid, Utils.split_words(info.title_hv))

      author_zh_map.upsert(uuid, Utils.split_words(info.author_zh))
      author_vi_map.upsert(uuid, Utils.split_words(info.author_vi))

      genres_vi_map.upsert(uuid, info.genres_vi.map { |x| Utils.slugify(x) })
      tags_vi_map.upsert(uuid, info.tags_vi.map { |x| Utils.slugify(x) })
    end

    book_rating.save!
    book_weight.save!
    book_access.save!
    book_update.save!

    title_zh_map.save!
    title_vi_map.save!
    title_hv_map.save!

    author_zh_map.save!
    author_vi_map.save!

    genres_vi_map.save!
    tags_vi_map.save!
  end
end

cmd = ConvertBookInfo.new

cmd.convert! unless ARGV.includes?("index_only")
cmd.make_slugs!
cmd.build_indexes!
