require "json"
require "colorize"
require "file_utils"

require "../../src/kernel/book_info"
require "../../src/kernel/book_misc"

require "../../src/kernel/mapper/map_value"
require "../../src/kernel/import/yousuu_info"

class MapYousuu
  DIR = File.join("var", "appcv", ".cache", "yousuu", "serials")

  def self.run!
    this = new
    this.load_inputs!
    this.extract_infos!
    this.extract_miscs!
  end

  def initialize
    @inputs = {} of String => YousuuInfo
    @author_file = "etc/author-whitelist.txt"
    @author_list = Set(String).new(File.read_lines(@author_file))
  end

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
    return false if @author_list.includes?(info.author)

    return false if info.score >= 2.5
    info.commentCount < 10 || info.addListTotal < 10
  end

  def add_to_whitelist(info : YousuuInfo)
    return unless qualified?(info)

    @author_list.add(info.author)
    File.open(@author_file, "a") { |io| io.puts(info.author) }
  end

  def extract_infos!
    weight_map = MapValue.load!("book_weight")
    rating_map = MapValue.load!("book_rating")

    insert_count = 0
    update_count = 0

    @inputs.each do |uuid, input|
      # primary info

      info = BookInfo.init!(input.title, input.author)

      info.add_genre(input.genre)
      info.add_tags(input.tags)

      info.set_voters(input.scorerCount)
      info.set_rating((input.score * 10).round / 10)
      info.fix_weight!

      if info.changed?
        if info.exist?
          update_count += 1
        else
          insert_count += 1
        end

        info.save!
      end

      # update indexes
      weight_map.data.upsert!(uuid, info.data.weight)
      rating_map.data.upsert!(uuid, info.data.scored)
    end

    weight_map.save!
    rating_map.save!

    puts "- INFOS: #{@inputs.size.colorize(:yellow)}, \
           INSERT: #{insert_count.colorize(:yellow)}, \
           UPDATE: #{update_count.colorize(:yellow)}."
  end

  def extract_miscs!
    update_map = MapValue.load!("book_update")
    access_map = MapValue.load!("book_access")
    # fresh = 0

    @inputs.each do |uuid, input|
      misc = BookMisc.init!(uuid)

      misc.set_intro(input.intro)
      misc.add_cover(input.cover)

      misc.shield = input.shielded ? 2 : 0
      misc.set_status(input.status)

      mftime = input.updateAt.to_unix_ms
      misc.set_mftime(mftime)

      update_map.data.upsert!(uuid, misc.mftime)
      access_map.data.upsert!(uuid, misc.mftime)

      misc.yousuu_link = "https://www.yousuu.com/book/#{input._id}"
      misc.origin_link = input.first_source || ""

      misc.word_count = input.countWord.round.to_i
      misc.crit_count = input.commentCount

      misc.save!
    end

    access_map.save!
    update_map.save!
    # puts "- FRESH: #{fresh.colorize(:yellow)}."
  end
end

MapYousuu.run!
