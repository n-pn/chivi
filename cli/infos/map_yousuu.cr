require "json"
require "colorize"
require "file_utils"

require "../../src/_utils/time_utils"
require "../../src/_utils/text_utils"

require "../../src/models/book_info"

require "../../src/lookup/label_map"
require "../../src/lookup/order_map"

require "../../src/parser/ys_serial"

class MapYousuu
  DIR = File.join("var", ".book_cache", "yousuu", "serials")

  @input_total = 0
  @input_count = 0
  @info_create = 0
  @info_update = 0

  @inputs = {} of String => YsSerial

  def initialize
    puts "\n[-- Load indexes --]".colorize.cyan.bold
    @top_authors = OrderMap.get_or_create("author--weight")
    @book_update = OrderMap.get_or_create("ubid--update")

    @map_ubids = LabelMap.get_or_create("sitemaps/yousuu--sbid--ubid")
    @map_titles = LabelMap.get_or_create("sitemaps/yousuu--sbid--title")
    @map_authors = LabelMap.get_or_create("sitemaps/yousuu--sbid--author")
  end

  def prepare! : Void
    puts "\n[-- Load inputs --]".colorize.cyan.bold

    files = Dir.glob(File.join(DIR, "*.json"))
    files.each do |file|
      @input_total += 1

      next unless info = YsSerial.load!(file)
      next if info.title.empty? || info.author.empty? || worthless?(info)

      ysid = info._id.to_s
      ubid = Utils.gen_ubid(info.title, info.author)

      @map_ubids.upsert(ysid, ubid)
      @map_titles.upsert(ysid, info.title)
      @map_authors.upsert(ysid, info.author)

      if old_info = @inputs[ubid]?
        next if old_info.updateAt >= info.updateAt
      end

      @input_count += 1
      @inputs[ubid] = info
    rescue err
      puts "- <ys_serial> #{file} err: #{err}".colorize(:red)
      File.delete(file)
    end
  end

  def worthless?(info : YsSerial)
    return true if SourceUtil.blacklist?(info.title)

    if weight = @top_authors.value(info.author)
      return false if weight >= 2000
    end

    info.score < 2.5 && info.addListTotal < 5 && info.commentCount < 10
  end

  def extract!
    puts "\n[-- Extract outputs --]".colorize.cyan.bold

    @inputs.each do |ubid, input|
      info = BookInfo.get_or_create(input.title, input.author, ubid)

      info.add_genre(input.genre)
      info.add_tags(input.tags)

      info.shield = input.shielded ? 2 : 0

      info.voters = input.scorerCount
      info.rating = (input.score * 10).round / 10
      info.fix_weight

      info.set_title(Utils.split_text(input.intro).join("\n"))
      info.mftime = Utils.correct_time(input.updateAt).to_unix_ms

      info.status = input.status
      info.add_cover(input.cover)

      info.word_count = input.countWord.round.to_i
      info.crit_count = input.commentCount

      info.yousuu_bid = input._id.to_s
      info.origin_url = input.first_source || ""

      next unless info.changed?
      info.save!

      if @book_update.has_key?(ubid)
        @info_update += 1
      else
        @info_create += 1
      end

      @top_authors.upsert(info.author_zh, info.weight)
      @book_update.upsert(ubid, info.mftime)
    end
  end

  def cleanup!
    puts "\n[-- Clean up --]".colorize.cyan.bold
    puts "- <INP> total: #{@input_total}, keeps: #{@input_count} ".colorize.yellow
    puts "- <OUT> create: #{@info_create}, update: #{@info_update}".colorize.yellow
    @map_ubids.save!
    @map_titles.save!
    @map_authors.save!

    @top_authors.save!
    @book_update.save!
  end
end

worker = MapYousuu.new
worker.prepare!
worker.extract!
worker.cleanup!
