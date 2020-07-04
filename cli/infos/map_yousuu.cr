require "json"
require "colorize"
require "file_utils"

require "../../src/kernel/book_info"
require "../../src/kernel/book_meta"

require "../../src/mapper/map_value"
require "../../src/import/yousuu_info"

require "../../src/utils/time_utils"
require "../../src/utils/text_utils"

class MapYousuu
  DIR = File.join("var", "appcv", ".cache", "yousuu", "serials")

  @input_total = 0
  @input_count = 0

  @info_create = 0
  @info_update = 0

  AUTHORS = MapValue.load!("best_authors")
  @inputs = {} of String => YousuuInfo

  def load_inputs! : Void
    files = Dir.glob(File.join(DIR, "*.json"))
    files.each { |file| parse_file!(file) }
  end

  def parse_file!(file : String) : Void
    @input_total += 1

    return unless info = YousuuInfo.load!(file)
    return if info.title.empty? || info.author.empty? || worthless?(info)

    uuid = Utils.gen_uuid(info.title, info.author)
    if old_info = @inputs[uuid]?
      return if old_info.updateAt >= info.updateAt
    end

    @input_count += 1
    @inputs[uuid] = info
  rescue err
    puts "- <read_json> #{file} err: #{err}".colorize(:red)
    File.delete(file)
  end

  def worthless?(info : YousuuInfo)
    if weight = AUTHORS.get_val(info.author)
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

  def extract_infos!
    rating_map = MapValue.load!("book_rating")
    weight_map = MapValue.load!("book_weight")

    @inputs.each do |uuid, input|
      # primary info

      info = BookInfo.find_or_create!(input.title, input.author, uuid)

      info.set_genre(input.genre)
      info.add_tags(input.tags)

      info.shield = input.shielded ? 2 : 0

      info.voters = input.scorerCount
      info.rating = (input.score * 10).round / 10
      info.fix_weight

      AUTHORS.upsert!(info.author_zh, info.weight)

      info.word_count = input.countWord.round.to_i
      info.crit_count = input.commentCount

      if info.changed?
        if BookInfo.exists?(uuid)
          @info_update += 1
        else
          @info_create += 1
        end

        info.save!
      end

      rating_map.data.upsert!(uuid, info.scored)
      weight_map.data.upsert!(uuid, info.weight)
    end

    rating_map.save!
    weight_map.save!
  end

  def initial_metas!
    update_map = MapValue.load!("book_update")
    access_map = MapValue.load!("book_access")
    # fresh = 0

    @inputs.each do |uuid, input|
      meta = BookMeta.get_or_create!(uuid)

      meta.intro_zh = Utils.split_text(input.intro).join("\n")
      meta.status = input.status
      meta.add_cover(input.cover)

      meta.yousuu_link = "https://www.yousuu.com/book/#{input._id}"
      meta.origin_link = input.first_source || ""

      mftime = Utils.correct_time(input.updateAt).to_unix_ms
      meta.mftime = mftime

      update_map.data.upsert!(uuid, meta.mftime)
      access_map.data.upsert!(uuid, meta.mftime)

      meta.save! if meta.changed?
    end

    access_map.save!
    update_map.save!
  end

  def cleanup!
    puts "- <INPUT> total: #{@input_total}, worth: #{@input_count} ".colorize(:yellow)
    puts "- <OUTPUT> create: #{@info_create}, update: #{@info_update}".colorize(:yellow)

    AUTHORS.save!
  end
end

mapper = MapYousuu.new
mapper.load_inputs!
mapper.extract_infos!
mapper.initial_metas!
mapper.cleanup!
