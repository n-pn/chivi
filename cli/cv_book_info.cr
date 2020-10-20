require "json"
require "colorize"
require "file_utils"

require "../src/kernel/models/book_info"

count = 0
BookInfo.load_all!.each do |info|
  count += 1 if info.seed_names.size > 0
end

puts count

# require "../src/_utils/text_utils"

# require "../src/filedb/label_map"
# require "../src/filedb/token_map"
# require "../src/filedb/value_set"

# require "../src/models/book_info"
# require "../src/models/chap_list"

# require "../src/engine"

# def hanviet(input : String)
#   return input unless input =~ /\p{Han}/
#   Engine.hanviet(input, apply_cap: true).vi_text
# end

# def cv_intro(input : String, dname : String) : String
#   Engine.cv_plain(input.split("\n"), dname).map(&.vi_text).join("\n")
# end

# def cv_title(input : String, dname : String) : String
#   Engine.cv_title(input, dname).vi_text
# end

# def cv_plain(input : String, dname : String) : String
#   Engine.cv_plain(input, dname).vi_text
# end

# TITLE_ZH  = LabelMap.load!("override/zh_title")
# AUTHOR_ZH = LabelMap.load!("override/zh_author")

# # move seed info from removed entry to remained entry
# private def transfer_info(remove : BookInfo, remain : BookInfo)
#   remove.seed_infos.each do |name, seed|
#     next if remain.seed_infos.has_key?(name)
#     remain.add_seed(name, seed.type)
#     remain.update_seed(name, seed.sbid, seed.mftime, seed.latest)
#   end

#   File.delete(BookInfo.path_for(remove.ubid))
#   FileUtils.rm_rf(ChapList.path_for(remove.ubid))

#   if remove.zh_title != remain.zh_title
#     TITLE_ZH.upsert!(remove.zh_title, remain.zh_title)
#   else
#     AUTHOR_ZH.upsert!(remove.zh_author, "#{remain.zh_author}¦#{remain.zh_title}")
#   end
# end

# def resolve_duplicate(old_info, new_info, slug)
#   puts old_info.to_json.colorize.cyan
#   puts new_info.to_json.colorize.cyan

#   old_title = old_info.zh_title
#   new_title = new_info.zh_title

#   old_author = old_info.zh_author
#   new_author = new_info.zh_author

#   if old_title != new_title
#     puts "\n[ fix title ]".colorize.cyan
#     puts "FIX 1 (keep old): `#{new_title} => #{old_title}`"
#     puts "FIX 2 (keep new): `#{old_title} => #{new_title}`"
#   end

#   if old_author != new_author
#     puts "\n[ fix author ]".colorize.cyan
#     puts "FIX 1 (keep old): `#{new_author} => #{old_author}`"
#     puts "FIX 2 (keep new): `#{old_author} => #{new_author}`"
#   end

#   print "\nPrompt (1: keep old, 2: keep new, else: skipping): ".colorize.blue

#   case gets.try(&.chomp)
#   when "1"
#     puts "- Keep old!!".colorize.yellow
#     transfer_info(remove: new_info, remain: old_info)
#   when "2"
#     puts "- Keep new!!".colorize.yellow
#     transfer_info(remove: old_info, remain: new_info)

#     FULL_SLUGS[slug] = new_info.ubid
#     SLUG_UBIDS.delete(slug)
#   else
#     puts "- Skipping for now!!"
#   end
# end

# SEEDS = {
#   "hetushu", "jx_la", "rengshu",
#   "xbiquge", "nofff", "duokan8",
#   "paoshu8", "69shu", "zhwenpg",
# }

# def seed_order(name : String) : Int32
#   SEEDS.index(name) || -1
# end

# puts "[-- Load inputs --]".colorize.cyan.bold

# INFOS = BookInfo.preload_all!
# INPUT = INFOS.values.sort_by(&.weight.-)

# HIATUS  = Time.utc(2019, 1, 1).to_unix_ms
# TITLES  = LabelMap.load!("override/vi_title")
# AUTHORS = LabelMap.load!("override/vi_author")

# FULL_SLUGS = {} of String => String
# SLUG_UBIDS = LabelMap.init("slug--ubid")

# puts "[-- Convert! --]".colorize.cyan.bold

# book_rating = OrderMap.init("rating")
# book_weight = OrderMap.init("weight")
# book_update = OrderMap.init("update")
# book_access = OrderMap.init("access")

# title_zh_map = TokenMap.init("zh_title")
# title_vi_map = TokenMap.init("vi_title")
# title_hv_map = TokenMap.init("hv_title")

# author_zh_map = TokenMap.init("zh_author")
# author_vi_map = TokenMap.init("vi_author")

# genres_vi_map = TokenMap.init("vi_genres")
# tags_vi_map = TokenMap.init("vi_tags")

# INPUT.each_with_index do |info, idx|
#   puts "\n- <#{idx + 1}/#{INPUT.size}> [#{info.ubid}] {#{info.slug}}".colorize.cyan

#   info.hv_title = hanviet(info.zh_title)
#   vi_title = TITLES.fetch(info.zh_title) || info.hv_title
#   info.vi_title = Utils.titleize(vi_title)

#   if vi_author = AUTHORS.fetch(info.zh_author)
#     info.vi_author = vi_author
#   else
#     info.vi_author = Utils.titleize(hanviet(info.zh_author))
#   end

#   info.zh_genres, info.vi_genres = map_genres(info)
#   info.vi_tags = info.zh_tags.map do |tag|
#     map_genre_vi(tag) || cv_plain(tag, "tonghop")
#   end

#   info.vi_intro = cv_intro(info.zh_intro, info.ubid)
#   info.status = 3 if info.status == 0 && info.mftime < HIATUS

#   info.seed_names = info.seed_names.sort_by { |x| seed_order(x) }

#   info.seed_infos.each_value do |seed|
#     latest = seed.latest
#     latest.vi_label = cv_title(latest.zh_label, info.ubid)
#     latest.vi_title = cv_title(latest.zh_title, info.ubid)
#     latest.set_slug(latest.vi_title)
#     info.update_seed(seed.name, seed.sbid, seed.mftime, latest)
#   end

#   title_slug = Utils.slugify(info.vi_title, no_accent: true)
#   author_slug = Utils.slugify(info.vi_author, no_accent: true)

#   full_slug = "#{title_slug}--#{author_slug}"
#   if old_ubid = FULL_SLUGS[full_slug]?
#     resolve_duplicate(INFOS[old_ubid], info, full_slug)
#   else
#     FULL_SLUGS[full_slug] = info.ubid
#   end

#   next unless FULL_SLUGS[full_slug] == info.ubid

#   if old_ubid = SLUG_UBIDS.fetch(title_slug)
#     info.slug = full_slug
#   else
#     info.slug = title_slug
#   end

#   info.save! if info.changed?

#   SLUG_UBIDS.upsert(info.slug, info.ubid)

#   hanviet_slug = Utils.slugify(info.hv_title, no_accent: true)
#   if hanviet_slug != title_slug
#     if SLUG_UBIDS.has_key?(hanviet_slug)
#       full_slug = "#{hanviet_slug}--#{author_slug}"

#       unless SLUG_UBIDS.has_key?(full_slug)
#         SLUG_UBIDS.upsert(full_slug, info.ubid)
#       end
#     else
#       SLUG_UBIDS.upsert(hanviet_slug, info.ubid)
#     end
#   end

#   book_rating.upsert(info.ubid, info.scored)
#   book_weight.upsert(info.ubid, info.weight)
#   book_update.upsert(info.ubid, info.mftime)
#   book_access.upsert(info.ubid, info.mftime)

#   title_zh_map.upsert(info.ubid, Utils.split_words(info.zh_title))
#   title_vi_map.upsert(info.ubid, Utils.split_words(info.vi_title))
#   title_hv_map.upsert(info.ubid, Utils.split_words(info.hv_title))

#   author_zh_map.upsert(info.ubid, Utils.split_words(info.zh_author))
#   author_vi_map.upsert(info.ubid, Utils.split_words(info.vi_author))

#   genres_slugs = info.vi_genres.map { |x| Utils.slugify(x) }
#   genres_vi_map.upsert(info.ubid, genres_slugs)

#   tags_slugs = info.vi_tags.map { |x| Utils.slugify(x) }
#   tags_vi_map.upsert(info.ubid, tags_slugs)
# end

# puts "[-- Save indexes! --]".colorize.cyan.bold

# book_rating.save!
# book_weight.save!
# book_access.save!
# book_update.save!

# title_zh_map.save!
# title_vi_map.save!
# title_hv_map.save!

# author_zh_map.save!
# author_vi_map.save!

# genres_vi_map.save!
# tags_vi_map.save!

# SLUG_UBIDS.save!
