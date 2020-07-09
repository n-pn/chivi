require "json"
require "colorize"
require "file_utils"

require "../../src/kernel/book_info"
require "../../src/kernel/order_map"

require "../../src/snipes/yousuu_info"

require "../../src/_utils/time_utils"
require "../../src/_utils/text_utils"

class MapYousuu
  DIR = File.join("var", ".book_cache", "yousuu", "serials")

  @input_total = 0
  @input_count = 0
  @info_create = 0
  @info_update = 0

  @book_rating = OrderMap.load("book_rating")
  @book_weight = OrderMap.load("book_weight")
  @book_update = OrderMap.load("book_update")
  @book_access = OrderMap.load("book_access")
  @top_authors = OrderMap.load("top_authors")

  @inputs = {} of String => YousuuInfo

  def prepare! : Void
    files = Dir.glob(File.join(DIR, "*.json"))
    files.each do |file|
      @input_total += 1

      next unless info = YousuuInfo.load!(file)
      next if info.title.empty? || info.author.empty? || worthless?(info)

      uuid = Utils.gen_uuid(info.title, info.author)
      if old_info = @inputs[uuid]?
        next if old_info.updateAt >= info.updateAt
      end

      @input_count += 1
      @inputs[uuid] = info
    rescue err
      puts "- <yousuu_info> #{file} err: #{err}".colorize(:red)
      File.delete(file)
    end
  end

  def worthless?(info : YousuuInfo)
    if weight = @top_authors.value(info.author)
      return false if weight >= 2000
    end

    info.score < 2.5 && info.addListTotal < 5 && info.commentCount < 10
  end

  def add_to_whitelist(info : YousuuInfo)
    return if WHITELIST_DATA.includes?(info.author)
    return unless qualified?(info)

    WHITELIST_DATA.add(info.author)
    File.open(WHITELIST_FILE, "a") { |io| io.puts(info.author) }
  end

  def extract!
    @inputs.each do |uuid, input|
      # primary info

      info = BookInfo.find_or_create(input.title, input.author, uuid, cache: false)

      info.set_genre(input.genre)
      info.add_tags(input.tags)

      info.shield = input.shielded ? 2 : 0

      info.voters = input.scorerCount
      info.rating = (input.score * 10).round / 10
      info.fix_weight

      if info.intro_zh.empty?
        info.intro_zh = Utils.split_text(input.intro).join("\n")
      end

      info.mftime = Utils.correct_time(input.updateAt).to_unix_ms

      info.status = input.status
      info.add_cover(input.cover)

      info.word_count = input.countWord.round.to_i
      info.crit_count = input.commentCount

      info.yousuu_url = "https://www.yousuu.com/book/#{input._id}"
      info.origin_url = input.first_source || ""

      if info.changed?
        if BookInfo.exists?(uuid)
          @info_update += 1
        else
          @info_create += 1
        end

        info.save!
      end

      @book_rating.upsert(uuid, info.scored)
      @book_weight.upsert(uuid, info.weight)
      @book_update.upsert(uuid, info.mftime)
      @book_access.upsert(uuid, info.mftime)
      @top_authors.upsert(info.author_zh, info.weight)
    end
  end

  def cleanup!
    puts "- <INP> total: #{@input_total}, keeps: #{@input_count} ".colorize(:yellow)
    puts "- <OUT> create: #{@info_create}, update: #{@info_update}".colorize(:yellow)

    @book_rating.save!
    @book_weight.save!
    @book_access.save!
    @book_update.save!
    @top_authors.save!
  end
end

mapper = MapYousuu.new
mapper.prepare!
mapper.extract!
mapper.cleanup!
