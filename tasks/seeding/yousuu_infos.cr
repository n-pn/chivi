require "file_utils"

require "../../src/filedb/nvinit/ys_info"
require "./_info_seeding.cr"

class CV::SeedInfoYousuu
  getter input = InfoSeeding.new("yousuu")

  getter source_url : ValueMap { ValueMap.new(input.map_path("source_url")) }
  getter count_word : ValueMap { ValueMap.new(input.map_path("count_word")) }
  getter count_crit : ValueMap { ValueMap.new(input.map_path("count_crit")) }
  getter count_list : ValueMap { ValueMap.new(input.map_path("count_list")) }

  def init!
    input = Dir.glob("_db/.cache/yousuu/infos/*.json").sort_by do |file|
      File.basename(file, ".json").to_i
    end

    puts "- Input: #{input.size} files.".colorize.cyan

    input.each_with_index do |file, idx|
      ybid = File.basename(file, ".json")

      access_tz = File.info(file).modification_time.to_unix
      next if @input.access_tz.fval(ybid).try(&.to_i64.>= access_tz)
      @input.access_tz.add(ybid, access_tz)

      next unless info = YsInfo.load(file)
      # puts "- <#{idx + 1}/#{input.size}> [#{info.title}  #{info.author}]".colorize.blue

      @input._index.add(ybid, [info.title, info.author])

      @input.bgenre.add(ybid, [info.genre].concat(info.tags_fixed))
      @input.bcover.add(ybid, info.cover_fixed)

      @input.status.add(ybid, [info.status.to_s, info.shielded ? "1" : "0"])
      @input.rating.add(ybid, [info.voters.to_s, info.rating.to_s])
      @input.update_tz.add(ybid, info.updated_at.to_unix)

      @input.set_intro(ybid, info.intro)

      source_url.add(ybid, info.source)
      count_word.add(ybid, info.word_count)
      count_crit.add(ybid, info.crit_count)
      count_list.add(ybid, info.addListTotal)

      if idx % 100 == 99
        puts "- [yousuu] <#{idx + 1}/#{input.size}>"
        save!(mode: :upds)
      end
    rescue err
      puts "- error loading [#{ybid}]: #{err}".colorize.red
    end

    save!(mode: :full)
  end

  def save!(mode : Symbol = :full)
    @input.save!(mode: mode)

    source_url.save!(mode: mode)
    count_word.save!(mode: mode)
    count_crit.save!(mode: mode)
    count_list.save!(mode: mode)
  end

  def seed!
  end
end

worker = CV::SeedInfoYousuu.new
worker.init! unless ARGV.includes?("-init")

worker.seed!
