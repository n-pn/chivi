require "../../src/kernel/book_repo"

def should_skip?(source : YsSerial)
  return true if BookRepo.blacklist?(source.title)
  return false if BookRepo.whitelist?(source.author)
  source.score < 2.5 && source.addListTotal < 5 && source.commentCount < 10
end

DIR = File.join("var", ".book_cache", "yousuu", "serials")
files = Dir.glob(File.join(DIR, "*.json")).sort_by do |file|
  File.basename(file, ".json").to_i
end

inp_total = inp_count = created = updated = 0
sitemap = LabelMap.load("sources/yousuu")

input = {} of String => YsSerial

files.each_with_index do |file, idx|
  inp_total += 1

  next unless source = YsSerial.load(file)

  source.title = BookRepo::Utils.fix_zh_title(source.title)
  source.author = BookRepo::Utils.fix_zh_author(source.author)

  ubid = UuidUtil.gen_ubid(source.title, source.author)
  sitemap.upsert(source.ysid, "#{ubid}¦#{source.title}¦#{source.author}")

  next if source.title.empty? || source.author.empty? || should_skip?(source)

  if existed = input[ubid]?
    next if existed.mftime > source.mftime
  end

  inp_count += 1
  input[ubid] = source
rescue err
  puts "- <map_yousuu> #{file} err: #{err}".colorize(:red)
  File.delete(file)
end

input.values.each_with_index do |source, idx|
  info = BookRepo.find_or_create(source.title, source.author, fixed: true)
  BookRepo.upsert_info(info)
  BookRepo.update_info(info, source)

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
  OrderMap.top_authors.upsert!(info.zh_author, info.weight) if info.weight >= 2000
end

puts "- <INP> total: #{inp_total}, keeps: #{inp_count} ".colorize.yellow
puts "- <OUT> create: #{created}, update: #{updated}".colorize.yellow

sitemap.save!
OrderMap.flush!
TokenMap.flush!
LabelMap.flush!
