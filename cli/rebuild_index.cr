require "json"
require "colorize"
require "file_utils"

require "../src/common/text_util"
require "../src/bookdb/book_info"
require "../src/kernel/book_repo"

def fix_indexes(info : BookInfo)
  # update tokens
  BookRepo.upsert_info(info, force: true)
  BookRepo::Utils.update_token(TokenMap.vi_genres, info.ubid, info.vi_genres)
  BookRepo::Utils.update_token(TokenMap.vi_tags, info.ubid, info.vi_tags)

  # update orders
  BookRepo::Utils.update_order(OrderMap.book_update, info.ubid, info.mftime)
  BookRepo::Utils.update_order(OrderMap.book_access, info.ubid, info.mftime)
  BookRepo::Utils.update_order(OrderMap.book_rating, info.ubid, info.scored)
  BookRepo::Utils.update_order(OrderMap.book_weight, info.ubid, info.weight)

  info.save! if info.changed?
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

OrderMap.flush!
TokenMap.flush!

# puts "- has_text: #{has_text}".colorize(:yellow)

# conflicts.reject! do |key, vals|
#   vals.size == 1
# end

# File.write "tmp/conflicts.json", conflicts.to_pretty_json
