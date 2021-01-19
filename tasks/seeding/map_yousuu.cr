require "file_utils"

require "../../src/_seeds/ys_info"
require "./_info_seed.cr"

class CV::Seeds::MapYousuu
  getter source_url : ValueMap { ValueMap.new(@seeding.map_path("source_url")) }
  getter count_word : ValueMap { ValueMap.new(@seeding.map_path("count_word")) }
  getter count_crit : ValueMap { ValueMap.new(@seeding.map_path("count_crit")) }
  getter count_list : ValueMap { ValueMap.new(@seeding.map_path("count_list")) }

  def initialize
    @seeding = InfoSeed.new("yousuu")
  end

  def init!
    input = Dir.glob("_db/.cache/yousuu/infos/*.json").sort_by do |file|
      File.basename(file, ".json").to_i
    end

    puts "- Input: #{input.size} files.".colorize.cyan

    input.each_with_index(1) do |file, idx|
      s_nvid = File.basename(file, ".json")

      atime = File.info(file).modification_time.to_unix
      next if @seeding._atime.ival_64(s_nvid) >= atime
      @seeding._atime.add(s_nvid, atime)

      next unless info = YsInfo.load(file)

      @seeding._index.add(s_nvid, [info.title, info.author])

      @seeding.genres.add(s_nvid, [info.genre].concat(info.tags_fixed))
      @seeding.bcover.add(s_nvid, info.cover_fixed)

      @seeding.status.add(s_nvid, info.status)
      @seeding.hidden.add(s_nvid, info.shielded ? "1" : "0")

      @seeding.rating.add(s_nvid, [info.voters.to_s, info.rating.to_s])
      @seeding._utime.add(s_nvid, info.updated_at.to_unix)

      @seeding.set_intro(s_nvid, info.intro)

      source_url.add(s_nvid, info.source)
      count_word.add(s_nvid, info.word_count)
      count_crit.add(s_nvid, info.crit_count)
      count_list.add(s_nvid, info.addListTotal)

      if idx % 100 == 0
        puts "- [yousuu] <#{idx}/#{input.size}>".colorize.cyan
        save!(mode: :upds)
      end
    rescue err
      puts "- error loading [#{s_nvid}]: #{err}".colorize.red
    end

    save!(mode: :full)
  end

  private def save!(mode : Symbol = :full)
    @seeding.save!(mode: mode)

    @source_url.try(&.save!(mode: mode))
    @count_word.try(&.save!(mode: mode))
    @count_crit.try(&.save!(mode: mode))
    @count_list.try(&.save!(mode: mode))
  end

  def seed!(mode : Symbol = :best)
    authors = Set(String).new(NvValues.author.vals.map(&.first))
    checked = Set(String).new

    input = @seeding.rating.data.to_a.map { |k, v| {k, v[0].to_i, v[1].to_i} }
    input.sort_by! { |a, b, c| -b }

    input.each_with_index(1) do |(s_nvid, voters, rating), idx|
      btitle, author = @seeding._index.get(s_nvid).not_nil!
      btitle, author = NvHelper.fix_nvname(btitle, author)
      next if btitle.empty? || author.empty?

      nvname = "#{btitle}\t#{author}"
      next if checked.includes?(nvname)
      checked.add(nvname)

      if (voters > 10 && rating >= 3.75) || authors.includes?(author) || popular?(s_nvid)
        authors.add(author)

        b_hash, existed = @seeding.upsert!(s_nvid)
        NvValues.set_score(b_hash, voters, rating)

        origin = source_url.fval(s_nvid)
        NvValues.origin.add(b_hash, origin) if origin && !origin.empty?

        NvValues.yousuu.add(b_hash, s_nvid)
        NvValues.hidden.add(b_hash, @seeding.hidden.fval(s_nvid) || "0")
      end

      if idx % 100 == 0
        puts "- [yousuu] <#{idx}/#{input.size}>".colorize.blue
        Nvinfo.save!(mode: :upds)
      end
    rescue err
      puts s_nvid
      puts err.backtrace
    end

    Nvinfo.save!(mode: :full)
  end

  def popular?(s_nvid : String)
    return true if count_crit.fval(s_nvid).try(&.to_i.>= 5)
    return true if count_list.fval(s_nvid).try(&.to_i.>= 3)
    false
  end
end

worker = CV::Seeds::MapYousuu.new
worker.init! unless ARGV.includes?("-init")
worker.seed!
