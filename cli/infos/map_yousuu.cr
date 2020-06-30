require "json"
require "colorize"
require "file_utils"

require "../../src/kernel/book_info"
require "../../src/kernel/book_misc"

require "../../src/kernel/mapper/map_value"
require "../../src/kernel/import/yousuu_info"

class MapYousuu
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
    files = YousuuInfo.files
    files.each { |file| parse_file!(file) }
    puts "- TOTAL: #{files.size.colorize(:yellow)}."
  end

  def parse_file!(file : String) : Void
    return unless info = YousuuInfo.load!(file)
    return if worthless?(info)

    uuid = Utils.gen_uuid(info.title, info.author)

    if old_info = @inputs[uuid]?
      return if old_info.updateAt >= info.updateAt
    end

    @inputs[uuid] = info
  rescue err
    puts "- <read_json> #{file} err: #{err}".colorize(:red)
    File.delete(file)
  end

  def worthless?(info : YousuuInfo)
    return false if @author_list.includes?(info.author)
    info.worthless?
  end

  def add_to_whitelist(data : BookInfo::Data)
    return if data.weight < 5000
    return if @author_list.includes?(data.author_zh)

    @author_list.add(data.author_zh)
    File.open(@author_file, "a") { |io| io.puts(data.author_zh) }
  end

  def extract_infos!
    weight_map = MapValue.load!("book_weight")
    rating_map = MapValue.load!("book_rating")

    fresh = 0

    @inputs.each do |uuid, input|
      # primary info

      info = BookInfo.init!(input.title, input.author)
      fresh += 1 unless info.exist?

      info.add_genre(input.genre)
      info.add_tags(input.tags)

      info.set_voters(input.scorerCount)
      info.set_rating((input.score * 10).round / 10)
      info.fix_weight!

      add_to_whitelist(info.data)
      info.save! if info.changed?

      # update indexes
      weight_map.data.upsert!(uuid, info.data.weight)
      rating_map.data.upsert!(uuid, info.data.scored)
    end

    weight_map.save!
    rating_map.save!

    puts "- FRESH: #{fresh.colorize(:yellow)}."
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
