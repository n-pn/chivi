require "json"
require "colorize"
require "file_utils"

require "../src/_utils/text_utils"

require "../src/lookup/label_map"
require "../src/lookup/token_map"
require "../src/lookup/order_map"
require "../src/lookup/value_set"

require "../src/models/book_info"
require "../src/models/chap_list"

require "../src/engine"

def hanviet(input : String)
  return input unless input =~ /\p{Han}/
  Engine.hanviet(input, apply_cap: true).vi_text
end

def cv_intro(input : String, dname : String) : String
  Engine.cv_plain(input.split("\n"), dname).map(&.vi_text).join("\n")
end

def cv_title(input : String, dname : String) : String
  Engine.cv_title(input, dname).vi_text
end

def cv_plain(input : String, dname : String) : String
  Engine.cv_plain(input, dname).vi_text
end

def map_genre_vi(genre_zh)
  case genre_zh
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

def map_genre_zh(genre_zh)
  case genre_zh
  when "都市言情" then ["都市", "言情"]
  when "科幻空间" then ["科幻", "空间"]
  when "科幻灵异" then ["科幻", "灵异"]
  when "游戏竞技" then ["游戏", "竞技"]
  when "网游竞技" then ["游戏", "竞技"]
  when "武侠仙侠" then ["武侠", "仙侠"]
  when "修真武侠" then ["修真", "武侠"]
  when "历史军事" then ["历史", "军事"]
  when "幻想言情" then ["幻想", "言情"]
  when "悬疑惊悚" then ["悬疑", "惊悚"]
  when "玄幻魔法" then ["幻想", "魔法"]
  when "玄幻奇幻" then ["玄幻", "奇幻"]
  when "奇幻修真" then ["奇幻", "修真"]
  when "架空历史" then ["幻想", "历史"]
  when "官场职场" then ["官场", "职场"]
  when "总裁豪门" then ["都市", "言情"]
  when "耽美纯爱" then ["耽美", "女生"]
  when "青春校园" then ["校园", "都市"]
  when "衍生同人" then ["同人"]
  when "小说同人" then ["同人"]
  when "女生频道" then ["女生"]
  when "悬疑推理" then ["悬疑"]
  when "仙侠奇缘" then ["仙侠"]
  when "经典仙侠" then ["仙侠"]
  when "穿越时空" then ["穿越"]
  when "网游"   then ["游戏"]
  end
end

def map_genres(info) : Tuple(Array(String), Array(String))
  if info.genres_zh.empty? || info.genres_zh == ["其他"]
    return ["其他"], ["Loại khác"]
  end

  genres_zh = [] of String
  genres_vi = [] of String

  info.genres_zh.each do |genre_zh|
    if genre_vi = map_genre_vi(genre_zh)
      genres_zh << genre_zh
      genres_vi << genre_vi
    elsif genres = map_genre_zh(genre_zh)
      genres.each do |genre|
        genres_zh << genre
        genres_vi << map_genre_vi(genre).not_nil!
      end
    elsif genre_zh == "其他"
      # DO NOTHING!
    else
      genres_zh << genre_zh
      genres_vi << hanviet(genre_zh)
    end
  end

  {genres_zh.uniq, genres_vi.uniq}
end

TITLE_ZH  = LabelMap.load!("override/title_zh")
AUTHOR_ZH = LabelMap.load!("override/author_zh")

# move seed info from removed entry to remained entry
private def transfer_info(remove : BookInfo, remain : BookInfo)
  remove.seed_infos.each do |name, seed|
    next if remain.seed_infos.has_key?(name)
    remain.add_seed(name, seed.type)
    remain.update_seed(name, seed.sbid, seed.mftime, seed.latest)
  end

  File.delete(BookInfo.path_for(remove.ubid))
  FileUtils.rm_rf(ChapList.path_for(remove.ubid))

  if remove.title_zh != remain.title_zh
    TITLE_ZH.upsert!(remove.title_zh, remain.title_zh)
  else
    AUTHOR_ZH.upsert!(remove.author_zh, "#{remain.author_zh}¦#{remain.title_zh}")
  end
end

def resolve_duplicate(old_info, new_info, slug)
  puts old_info.to_json.colorize.cyan
  puts new_info.to_json.colorize.cyan

  old_title = old_info.title_zh
  new_title = new_info.title_zh

  old_author = old_info.author_zh
  new_author = new_info.author_zh

  if old_title != new_title
    puts "\n[ fix title ]".colorize.cyan
    puts "FIX 1 (keep old): `#{new_title} => #{old_title}`"
    puts "FIX 2 (keep new): `#{old_title} => #{new_title}`"
  end

  if old_author != new_author
    puts "\n[ fix author ]".colorize.cyan
    puts "FIX 1 (keep old): `#{new_author} => #{old_author}`"
    puts "FIX 2 (keep new): `#{old_author} => #{new_author}`"
  end

  print "\nPrompt (1: keep old, 2: keep new, else: skipping): ".colorize.blue

  case gets.try(&.chomp)
  when "1"
    puts "- Keep old!!".colorize.yellow
    transfer_info(remove: new_info, remain: old_info)
  when "2"
    puts "- Keep new!!".colorize.yellow
    transfer_info(remove: old_info, remain: new_info)

    FULL_SLUGS[slug] = new_info.ubid
    SLUG_UBIDS.delete(slug)
  else
    puts "- Skipping for now!!"
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

puts "[-- Load inputs --]".colorize.cyan.bold

INFOS = BookInfo.preload_all!
INPUT = INFOS.values.sort_by(&.weight.-)

HIATUS  = Time.utc(2019, 1, 1).to_unix_ms
TITLES  = LabelMap.load!("override/title_vi")
AUTHORS = LabelMap.load!("override/author_vi")

FULL_SLUGS = {} of String => String
SLUG_UBIDS = LabelMap.init("slug--ubid")

puts "[-- Convert! --]".colorize.cyan.bold

book_rating = OrderMap.init("ubid--rating")
book_weight = OrderMap.init("ubid--weight")
book_update = OrderMap.init("ubid--update")
book_access = OrderMap.init("ubid--access")

title_zh_map = TokenMap.init("ubid--title_zh")
title_vi_map = TokenMap.init("ubid--title_vi")
title_hv_map = TokenMap.init("ubid--title_hv")

author_zh_map = TokenMap.init("ubid--author_zh")
author_vi_map = TokenMap.init("ubid--author_vi")

genres_vi_map = TokenMap.init("ubid--genres_vi")
tags_vi_map = TokenMap.init("ubid--tags_vi")

INPUT.each_with_index do |info, idx|
  puts "\n- <#{idx + 1}/#{INPUT.size}> [#{info.ubid}] {#{info.slug}}".colorize.cyan

  info.title_hv = hanviet(info.title_zh)
  title_vi = TITLES.fetch(info.title_zh) || info.title_hv
  info.title_vi = Utils.titleize(title_vi)

  if author_vi = AUTHORS.fetch(info.author_zh)
    info.author_vi = author_vi
  else
    info.author_vi = Utils.titleize(hanviet(info.author_zh))
  end

  info.genres_zh, info.genres_vi = map_genres(info)
  info.tags_vi = info.tags_zh.map do |tag|
    map_genre_vi(tag) || cv_plain(tag, "tonghop")
  end

  info.intro_vi = cv_intro(info.intro_zh, info.ubid)
  info.status = 3 if info.status == 0 && info.mftime < HIATUS

  info.seed_names = info.seed_names.sort_by { |x| seed_order(x) }

  info.seed_infos.each_value do |seed|
    latest = seed.latest
    latest.label_vi = cv_title(latest.label_zh, info.ubid)
    latest.title_vi = cv_title(latest.title_zh, info.ubid)
    latest.set_slug(latest.title_vi)
    info.update_seed(seed.name, seed.sbid, seed.mftime, latest)
  end

  title_slug = Utils.slugify(info.title_vi, no_accent: true)
  author_slug = Utils.slugify(info.author_vi, no_accent: true)

  full_slug = "#{title_slug}--#{author_slug}"
  if old_ubid = FULL_SLUGS[full_slug]?
    resolve_duplicate(INFOS[old_ubid], info, full_slug)
  else
    FULL_SLUGS[full_slug] = info.ubid
  end

  next unless FULL_SLUGS[full_slug] == info.ubid

  if old_ubid = SLUG_UBIDS.fetch(title_slug)
    info.slug = full_slug
  else
    info.slug = title_slug
  end

  info.save! if info.changed?

  SLUG_UBIDS.upsert(info.slug, info.ubid)

  hanviet_slug = Utils.slugify(info.title_hv, no_accent: true)
  if hanviet_slug != title_slug
    if SLUG_UBIDS.has_key?(hanviet_slug)
      full_slug = "#{hanviet_slug}--#{author_slug}"

      unless SLUG_UBIDS.has_key?(full_slug)
        SLUG_UBIDS.upsert(full_slug, info.ubid)
      end
    else
      SLUG_UBIDS.upsert(hanviet_slug, info.ubid)
    end
  end

  book_rating.upsert(info.ubid, info.scored)
  book_weight.upsert(info.ubid, info.weight)
  book_update.upsert(info.ubid, info.mftime)
  book_access.upsert(info.ubid, info.mftime)

  title_zh_map.upsert(info.ubid, Utils.split_words(info.title_zh))
  title_vi_map.upsert(info.ubid, Utils.split_words(info.title_vi))
  title_hv_map.upsert(info.ubid, Utils.split_words(info.title_hv))

  author_zh_map.upsert(info.ubid, Utils.split_words(info.author_zh))
  author_vi_map.upsert(info.ubid, Utils.split_words(info.author_vi))

  genres_slugs = info.genres_vi.map { |x| Utils.slugify(x) }
  genres_vi_map.upsert(info.ubid, genres_slugs)

  tags_slugs = info.tags_vi.map { |x| Utils.slugify(x) }
  tags_vi_map.upsert(info.ubid, tags_slugs)
end

puts "[-- Save indexes! --]".colorize.cyan.bold

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

SLUG_UBIDS.save!
