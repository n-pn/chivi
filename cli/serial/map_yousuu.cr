require "../../src/kernel/bookdb"

def should_keep?(source : YsSerial)
  return false if source.title.empty? || source.author.empty?
  return false if BookDB.blacklist?(source.title)

  return true if source.addListTotal >= 6 || source.commentCount >= 12
  return true if source.score >= 3.25 && source.scorerCount >= 10

  BookDB.whitelist?(source.author)
end

DIR = "_db/seeds/yousuu/raw-infos"
files = Dir.glob(File.join(DIR, "*.json")).sort_by do |file|
  File.basename(file, ".json").to_i
end

inp_total = inp_count = created = updated = 0
sitemap = Oldcv::LabelMap.load_name("_import/sites/yousuu")

input = {} of String => YsSerial

files.each_with_index do |file, idx|
  inp_total += 1

  next unless source = YsSerial.load(file)

  source.title = BookDB::Utils.fix_zh_title(source.title)
  source.author = BookDB::Utils.fix_zh_author(source.author)

  ubid = UuidUtil.gen_ubid(source.title, source.author)
  sitemap.upsert(source.ysid, "#{ubid}¦#{source.title}¦#{source.author}")

  next unless should_keep?(source)

  if existed = input[ubid]?
    next if existed.mftime > source.mftime
  end

  inp_count += 1
  input[ubid] = source
rescue err
  puts "- <map_yousuu> #{file} err: #{err}".colorize(:red)
  File.delete(file)
end

input = input.values.sort_by(&.weight.-)
input.each_with_index do |source, idx|
  info = BookDB.find_or_create(source.title, source.author, fixed: true)
  BookDB.upsert_info(info)
  BookDB.update_info(info, source)

  next unless info.changed?

  if BookInfo.exists?(info.ubid)
    updated += 1
    color = :blue
  else
    created += 1
    color = :cyan
  end

  puts "\n- <#{idx + 1}/#{input.size}> #{info.zh_title} ".colorize(color)

  info.save!
  OrderMap.author_voters.upsert!(info.zh_author, info.voters.to_i64)
  OrderMap.author_rating.upsert!(info.zh_author, info.scored)
  OrderMap.author_weight.upsert!(info.zh_author, info.weight)
end

puts "- <INP> total: #{inp_total}, keeps: #{inp_count} ".colorize.yellow
puts "- <OUT> create: #{created}, update: #{updated}".colorize.yellow

sitemap.save!
OrderMap.flush!
Oldcv::TokenMap.flush!
Oldcv::LabelMap.flush!
