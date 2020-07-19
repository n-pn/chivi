require "../../src/kernel/book_repo"

def should_skip?(info : BookInfo, source : YsSerial)
  if info.yousuu_bid != source.ysid
    return true if info.crit_count > source.crit_count
  end

  return true if BookRepo.blacklist?(info)
  return false if BookRepo.whitelist?(info)
  source.score < 2.5 && source.addListTotal < 5 && source.commentCount < 10
end

DIR = File.join("var", ".book_cache", "yousuu", "serials")
files = Dir.glob(File.join(DIR, "*.json")).sort_by do |file|
  File.basename(file, ".json").to_i
end

inp_total = inp_count = created = updated = 0
sitemap = LabelMap.preload!("yousuu-data")

files.each do |file|
  inp_total += 1

  next unless source = YsSerial.load(file)
  next if source.title.empty? || source.author.empty?

  info = BookRepo.find_or_create(source.title, source.author, fixed: false)
  sitemap.upsert(source.ysid, "#{info.ubid}¦#{info.zh_title}¦#{info.zh_author}¦#{Time.utc.to_unix}")

  next if should_skip?(info, source)
  inp_count += 1

  BookRepo.reset_info(info) if info.slug.empty?
  BookRepo.update(info, source)

  next unless info.changed?
  fresh = BookInfo.exists?(info.ubid)

  if fresh
    created += 1
  else
    updated += 1
  end

  info.save!

  if info.weight >= 2000
    OrderMap.top_authors.upsert!(info.zh_author, info.weight)
  end
rescue err
  puts "- <map_yousuu> #{file} err: #{err}".colorize(:red)
  File.delete(file)
end

puts "- <INP> total: #{inp_total}, keeps: #{inp_count} ".colorize.yellow
puts "- <OUT> create: #{created}, update: #{updated}".colorize.yellow

sitemap.save!
OrderMap.flush!
TokenMap.flush!
LabelMap.flush!
