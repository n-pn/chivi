require "json"
require "colorize"
require "file_utils"

require "../../src/kernel/book_info"
require "../../src/kernel/book_misc"

require "../../src/kernel/mapper/map_value"
require "../../src/kernel/import/yousuu_info"

require "../../src/utils/time_utils"
require "../../src/utils/text_utils"

class MapYousuu
  DIR = File.join("var", "appcv", ".cache", "yousuu", "serials")

  WHITELIST_FILE = File.join("etc", "author-whitelist.txt")
  WHITELIST_DATA = Set(String).new File.read_lines(WHITELIST_FILE)

  @inputs = {} of String => YousuuInfo

  def load_inputs! : Void
    files = Dir.glob(File.join(DIR, "*.json"))
    puts "- INPUT: #{files.size.colorize(:yellow)}."

    files.each { |file| parse_file!(file) }
  end

  def parse_file!(file : String) : Void
    return unless info = YousuuInfo.load!(file)

    return if worthless?(info)
    add_to_whitelist(info)

    uuid = Utils.gen_uuid(info.title, info.author)

    if old_info = @inputs[uuid]?
      return if old_info.updateAt >= info.updateAt
    end

    @inputs[uuid] = info
  rescue err
    puts "- <read_json> #{file} err: #{err}".colorize(:red)
    File.delete(file)
  end

  def qualified?(info : YousuuInfo)
    return true if info.score > 7 && info.scorerCount > 20
    return true if info.score > 6 && info.scorerCount > 30
    return true if info.score > 5 && info.scorerCount > 40
    return true if info.score > 4 && info.scorerCount > 50

    info.scorerCount > 100
  end

  def worthless?(info : YousuuInfo)
    return true if info.title.empty?
    return true if info.author.empty?
    return false if qualified?(info)
    return false if WHITELIST_DATA.includes?(info.author)

    return false if info.score >= 2.5
    info.commentCount < 10 || info.addListTotal < 10
  end

  def add_to_whitelist(info : YousuuInfo)
    return if WHITELIST_DATA.includes?(info.author)
    return unless qualified?(info)

    WHITELIST_DATA.add(info.author)
    File.open(WHITELIST_FILE, "a") { |io| io.puts(info.author) }
  end

  def extract_infos!
    # weight_map = MapValue.load!("book_weight")
    # rating_map = MapValue.load!("book_rating")

    update_count = 0

    @inputs.each do |uuid, input|
      # primary info

      info = BookInfo.find_or_create!(input.title, input.author)

      # info.genre_zh = Utils.fix_genre(input.genre)
      info.genre_zh = input.genre

      info.voters = input.scorerCount
      info.rating = (input.score * 10).round / 10
      info.fix_weight!

      update_count += 1 if info.changed?

      # weight_map.data.upsert!(uuid, info.data.weight)
      # rating_map.data.upsert!(uuid, info.data.scored)
    end

    # weight_map.save!
    # rating_map.save!

    BookInfo.save_all!
    puts "- TOTAL: #{@inputs.size.colorize(:yellow)}, \
           UPDATE: #{update_count.colorize(:yellow)}."
  end

  def extract_miscs!
    # update_map = MapValue.load!("book_update")
    # access_map = MapValue.load!("book_access")
    # fresh = 0

    @inputs.each do |uuid, input|
      misc = BookMisc.get_or_create!(uuid)

      misc.intro_zh = Utils.split_text(input.intro).join("\n")
      misc.add_tags(input.tags)
      misc.add_cover(input.cover)

      misc.shield = input.shielded ? 2 : 0
      misc.status = input.status

      mftime = Utils.correct_time(input.updateAt).to_unix_ms
      misc.mftime = mftime

      # update_map.data.upsert!(uuid, misc.mftime)
      # access_map.data.upsert!(uuid, misc.mftime)

      misc.yousuu_link = "https://www.yousuu.com/book/#{input._id}"
      misc.origin_link = input.first_source || ""

      misc.word_count = input.countWord.round.to_i
      misc.crit_count = input.commentCount

      BookMisc.save!(misc) if misc.changed?
    end

    # access_map.save!
    # update_map.save!
    # puts "- FRESH: #{fresh.colorize(:yellow)}."
  end
end

mapper = MapYousuu.new
mapper.load_inputs!
mapper.extract_infos!
mapper.extract_miscs!
