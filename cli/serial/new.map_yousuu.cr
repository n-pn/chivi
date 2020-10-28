require "file_utils"

require "../../src/filedb/*"
require "../../src/_seeds/yousuu_info"

class MapYousuu
  INP_DIR = "_db/inits/seeds/yousuu/_infos"
  OUT_DIR = "_db/inits/seeds/yousuu/infos"
  FileUtils.mkdir_p(OUT_DIR)

  def initialize(preload = true)
    @bnames = load_map("bnames", preload)

    @intros = load_map("intros", preload)
    @covers = load_map("covers", preload)

    @tags = load_map("tags", preload)
    @genres = load_map("genres", preload)

    @rating = load_map("rating", preload)
    @status = load_map("status", preload)

    @word_count = load_map("word_count", preload)
    @crit_count = load_map("crit_count", preload)

    @mtimes = load_map("mtimes", preload)
    @utimes = load_map("utimes", preload)
  end

  @maps = {} of String => ValueMap

  def load_map(type : String, preload = true)
    @maps[type] ||= ValueMap.new("#{OUT_DIR}/#{type}.tsv", preload)
  end

  def save_maps!
    @maps.each(&.save!)
  end

  def update_infos!
    total = Dir.glob("#{INP_DIR}/*.json")
    input = total.reject { |file| file_outdated?(file) }

    puts "- Input: #{input.size}(/#{total.size}) files.".colorize.cyan

    files.each_with_index do |file, idx|
      data = YousuuInfo.load(file)

      bname = "#{data.title}  #{data.author}"
      puts "- <#{idx + 1}/#{input.size}> #{bname}".colorize.blue

      @bnames.update
    rescue err
      puts "- error loading #{file}: #{err}".colorize.red
    end
  end

  def file_outdated?(file : String)
    y_bid = File.basename(file, ".json")
    return false unless utime = @utimes.fetch(y_bid).try(&.rtime)
    utime + 10.minutes < File.info(file).modification_time
  end
end

worker = MapYousuu.new
worker.update_infos!

# files = Dir.glob(File.join(DIR, "*.json")).sort_by do |file|
#   File.basename(file, ".json").to_i
# end

# inp_total = inp_count = created = updated = 0
# sitemap = OldLabelMap.load_name("_import/sites/yousuu")

# input = {} of String => YousuuInfo

# files.each_with_index do |file, idx|
#   inp_total += 1

#   next unless source = YousuuInfo.load(file)

#   source.title = BookDB::Utils.fix_zh_title(source.title)
#   source.author = BookDB::Utils.fix_zh_author(source.author)

#   ubid = UuidUtil.gen_ubid(source.title, source.author)
#   sitemap.upsert(source.ysid, "#{ubid}¦#{source.title}¦#{source.author}")

#   next unless should_keep?(source)

#   if existed = input[ubid]?
#     next if existed.mftime > source.mftime
#   end

#   inp_count += 1
#   input[ubid] = source
# rescue err
#   puts "- <map_yousuu> #{file} err: #{err}".colorize(:red)
#   File.delete(file)
# end

# input = input.values.sort_by(&.weight.-)
# input.each_with_index do |source, idx|
#   info = BookDB.find_or_create(source.title, source.author, fixed: true)
#   BookDB.upsert_info(info)
#   BookDB.update_info(info, source)

#   next unless info.changed?

#   if BookInfo.exists?(info.ubid)
#     updated += 1
#     color = :blue
#   else
#     created += 1
#     color = :cyan
#   end

#   puts "\n- <#{idx + 1}/#{input.size}> #{info.zh_title} ".colorize(color)

#   info.save!
#   OldOrderMap.author_voters.upsert!(info.zh_author, info.voters.to_i64)
#   OldOrderMap.author_rating.upsert!(info.zh_author, info.scored)
#   OldOrderMap.author_weight.upsert!(info.zh_author, info.weight)
# end

# puts "- <INP> total: #{inp_total}, keeps: #{inp_count} ".colorize.yellow
# puts "- <OUT> create: #{created}, update: #{updated}".colorize.yellow

# sitemap.save!
# OldOrderMap.flush!
# OldTokenMap.flush!
# OldLabelMap.flush!
