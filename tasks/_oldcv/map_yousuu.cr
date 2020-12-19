require "../../src/_oldcv/kernel/bookdb"

class Oldcv::MapYousuu
  DIR = "_db/.cache/yousuu/infos"

  getter input = {} of String => YsSerial

  def initialize
    @inp_total = @inp_count = @created = @updated = 0
  end

  def load!
    files = Dir.glob(File.join(DIR, "*.json")).sort_by do |file|
      File.basename(file, ".json").to_i
    end

    files.each_with_index do |file, idx|
      next unless source = YsSerial.load(file)
      @inp_total += 1

      source.title = BookDB::Utils.fix_zh_title(source.title)
      source.author = BookDB::Utils.fix_zh_author(source.author)

      ubid = UuidUtil.gen_ubid(source.title, source.author)
      next unless should_keep?(source)

      if existed = @input[ubid]?
        next if existed.mftime > source.mftime
      end

      @inp_count += 1
      @input[ubid] = source
    rescue err
      puts "- <map_yousuu> #{file} err: #{err}".colorize(:red)
    end
  end

  def should_keep?(source : YsSerial)
    return false if source.title.empty? || source.author.empty?
    return false if BookDB.blacklist?(source.title)

    return true if source.addListTotal >= 3 || source.commentCount >= 3
    return true if source.score >= 3 && source.scorerCount >= 5

    BookDB.whitelist?(source.author)
  end

  def parse!
    input = @input.values.sort_by(&.weight.-)
    input.each_with_index do |source, idx|
      info = BookDB.find_or_create(source.title, source.author, fixed: true)
      BookDB.upsert_info(info)
      BookDB.update_info(info, source)

      next unless info.changed?

      if BookInfo.exists?(info.ubid)
        @updated += 1
        color = :blue
      else
        @created += 1
        color = :cyan
      end

      puts "\n- <#{idx + 1}/#{input.size}> #{info.zh_title} ".colorize(color)

      info.save!
      OrderMap.author_voters.upsert!(info.zh_author, info.voters.to_i64)
      OrderMap.author_rating.upsert!(info.zh_author, info.scored)
      OrderMap.author_weight.upsert!(info.zh_author, info.weight)
    end
  end

  def save!
    puts "- <INP> total: #{@inp_total}, keeps: #{@inp_count} ".colorize.yellow
    puts "- <OUT> create: #{@created}, update: #{@updated}".colorize.yellow

    OrderMap.flush!
    TokenMap.flush!
    LabelMap.flush!
  end
end

worker = Oldcv::MapYousuu.new

worker.load!
worker.parse!
worker.save!
