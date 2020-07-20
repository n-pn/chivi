require "json"
require "colorize"
require "file_utils"

require "../src/common/text_util"
require "../src/bookdb/book_info"
require "../src/kernel/book_repo"

ACCESS = OrderMap.init("indexes/orders/book_access")

UPDATE = OrderMap.init("indexes/orders/book_update")
RATING = OrderMap.init("indexes/orders/book_rating")
WEIGHT = OrderMap.init("indexes/orders/book_weight")

GENRES = TokenMap.init("indexes/tokens/vi_genres")
TAGS   = TokenMap.init("indexes/tokens/vi_tags")

def fix_indexes(info : BookInfo)
  # update tokens
  BookRepo.upsert_info(info, force: true)
  info.save! if info.changed?

  BookRepo::Utils.update_token(GENRES, info.ubid, info.vi_genres)
  BookRepo::Utils.update_token(TAGS, info.ubid, info.vi_tags)

  # update orders
  BookRepo::Utils.update_order(UPDATE, info.ubid, info.mftime)
  BookRepo::Utils.update_order(ACCESS, info.ubid, info.weight)
  BookRepo::Utils.update_order(RATING, info.ubid, info.scored)
  BookRepo::Utils.update_order(WEIGHT, info.ubid, info.weight)
end

infos = BookInfo.load_all!
has_text = 0
conflicts = Hash(String, Array(String)).new { |h, k| h[k] = [] of String }

infos.sort_by!(&.weight.-)

infos.each_with_index do |info, idx|
  puts "\n- <#{idx + 1}/#{infos.size}> #{info.slug}".colorize.cyan
  has_text += 1 unless info.seed_names.empty?
  fix_indexes(info)

  title = info.zh_title.gsub(/\P{Han}/, "")
  author = info.zh_author.gsub(/\P{Han}/, "")
  conflicts["#{title}--#{author}"] << "#{info.zh_title}--#{info.zh_author}"
end

TokenMap.flush!

ACCESS.save!
UPDATE.save!
RATING.save!
WEIGHT.save!

GENRES.save!
TAGS.save!

puts "- has_text: #{has_text}".colorize(:yellow)

conflicts.reject! do |key, vals|
  vals.size == 1
end

File.write "tmp/conflicts.json", conflicts.to_pretty_json
