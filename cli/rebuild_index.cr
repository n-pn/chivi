require "json"
require "colorize"
require "file_utils"

require "../src/utils/text_util"
require "../src/appcv/models/book_info"
require "../src/appcv/bookdb"

ACCESS = OrderMap.load_name("indexes/orders/book_access", mode: 0)
UPDATE = OrderMap.load_name("indexes/orders/book_update", mode: 0)
RATING = OrderMap.load_name("indexes/orders/book_rating", mode: 0)
WEIGHT = OrderMap.load_name("indexes/orders/book_weight", mode: 0)

GENRES = TokenMap.init("indexes/tokens/vi_genres")
TAGS   = TokenMap.init("indexes/tokens/vi_tags")

EPOCH = Time.utc(2020, 1, 1).to_unix_ms

SEEDS = {
  "hetushu", "xbiquge", "69shu",
  "biquge5200", "5200", "zhwenpg",
  "duokan8", "rengshu", "nofff",
  "paoshu8", "kenwen", "mxguan",
  "shubaow", "jx_la", "qu_la",
}

def fix_indexes(info : BookInfo)
  # update tokens
  BookDB.upsert_info(info, force: true)

  # fix seeds' mftime
  changed = false
  {"hetushu", "69shu", "zhwenpg"}.each do |seed|
    next unless mftime = info.seed_mftimes[seed]?

    if mftime < info.mftime
      info.seed_mftimes[seed] = info.mftime
      changed = true
    end
  end

  # fix status
  if info.status == 0 && info.mftime < EPOCH
    info.status = 3
    changed = true
  end

  info.seed_names = info.seed_names.sort_by { |s| SEEDS.index(s) || -1 }
  info.save! if changed || info.changed?

  BookDB::Utils.update_token(GENRES, info.ubid, info.vi_genres)
  BookDB::Utils.update_token(TAGS, info.ubid, info.vi_tags)

  # update orders
  BookDB::Utils.update_order(UPDATE, info.ubid, info.mftime)
  BookDB::Utils.update_order(ACCESS, info.ubid, info.weight)
  BookDB::Utils.update_order(RATING, info.ubid, info.scored)
  BookDB::Utils.update_order(WEIGHT, info.ubid, info.weight)
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

# TokenMap.flush!

ACCESS.save!
UPDATE.save!
RATING.save!
WEIGHT.save!

GENRES.save!
TAGS.save!

puts "- has_text: #{has_text}".colorize(:yellow)

conflicts.reject! { |key, vals| vals.size == 1 }
File.write "tmp/conflicts.json", conflicts.to_pretty_json
