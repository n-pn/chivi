require "json"
require "colorize"
require "file_utils"

# require "../../src/lookup/label_map"
# require "../../src/lookup/order_map"
# require "../../src/bookdb/book_info"
# require "../../src/parser/ys_serial"
require "../../src/kernel/book_manage"

class MapYousuu
  DIR = File.join("var", ".book_cache", "yousuu", "serials")

  @inp_total = 0
  @inp_count = 0
  @out_created = 0
  @out_updated = 0

  @inputs = {} of String => YsSerial

  def initialize
    puts "\n[-- Load indexes --]".colorize.cyan.bold
    @authors = OrderMap.get_or_create("top_authors")
    @sitemap = LabelMap.get_or_create("sites/yousuu")
  end

  def prepare! : Void
    puts "\n[-- Load inputs --]".colorize.cyan.bold

    files = Dir.glob(File.join(DIR, "*.json"))
    files.each do |file|
      @inp_total += 1

      next unless serial = YsSerial.load(file)
      next if serial.title.empty? || serial.author.empty?

      serial.title = BookManage.fix_title(serial.title)
      serial.author = BookManage.fix_author(serial.author, serial.title)

      ubid = UuidUtil.gen_ubid(serial.title, serial.author)
      @sitemap.upsert(serial.ysid, "#{ubid}¦#{serial.title}¦#{serial.author}")

      next if worthless?(serial)

      if old_serial = @inputs[ubid]?
        next if old_serial.updateAt >= serial.updateAt
      end

      @inp_count += 1
      @inputs[ubid] = serial
    rescue err
      puts "- <map_yousuu> #{file} err: #{err}".colorize(:red)
      File.delete(file)
    end
  end

  def worthless?(info : YsSerial)
    return true if BookManage.blacklist?(info.title)
    return false if @authors.has_key?(info.author)
    info.score < 2.5 && info.addListTotal < 5 && info.commentCount < 10
  end

  def extract!
    puts "\n[-- Extract outputs --]".colorize.cyan.bold

    index = 0
    @inputs.each do |ubid, serial|
      index += 1

      if BookInfo.exists?(ubid)
        @out_updated += 1
        color = :blue
      else
        @out_created += 1
        color = :cyan
      end

      puts "\n- <#{index}/#{@inputs.size}> #{serial.title}--#{serial.author}".colorize(:color)

      output = BookManage.upsert!(serial, flush: true)
      @authors.upsert(output.zh_author, output.weight) if output.weight >= 1500
    rescue err
      puts serial.to_json
      puts err
      gets
    end

    puts "- <INP> total: #{@inp_total}, keeps: #{@inp_count} ".colorize.yellow
    puts "- <OUT> create: #{@out_created}, update: #{@out_updated}".colorize.yellow
    @authors.save!
    @sitemap.save!

    OrderMap.flush!
    TokenMap.flush!
  end

  def cleanup!
    puts "\n[-- Clean up --]".colorize.cyan.bold
  end
end

worker = MapYousuu.new
worker.prepare!
worker.extract!
