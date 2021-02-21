require "file_utils"

require "../../src/source/ys_nvinfo"
require "./_seeding.cr"

class CV::Seeds::MapYousuu
  getter source_url : ValueMap { ValueMap.new(@seeding.map_path("source_url")) }
  getter count_word : ValueMap { ValueMap.new(@seeding.map_path("count_word")) }
  getter count_crit : ValueMap { ValueMap.new(@seeding.map_path("count_crit")) }
  getter count_list : ValueMap { ValueMap.new(@seeding.map_path("count_list")) }

  def initialize
    @seeding = InfoSeed.new("yousuu")
  end

  def init!
    input = Dir.glob("_db/yousuu/.cache/infos/*.json").sort_by do |file|
      File.basename(file, ".json").to_i
    end

    puts "- Input: #{input.size} files.".colorize.cyan

    input.each_with_index(1) do |file, idx|
      snvid = File.basename(file, ".json")

      atime = File.info(file).modification_time.to_unix
      next if @seeding._atime.ival_64(snvid) >= atime
      @seeding._atime.add(snvid, atime)

      next unless info = YsNvinfo.load(file)

      @seeding._index.add(snvid, [info.title, info.author])

      @seeding.genres.add(snvid, [info.genre].concat(info.tags_fixed))
      @seeding.bcover.add(snvid, info.cover_fixed)

      @seeding.status.add(snvid, info.status)
      @seeding.hidden.add(snvid, info.shielded ? "1" : "0")

      @seeding.rating.add(snvid, [info.voters.to_s, info.rating.to_s])
      @seeding._utime.add(snvid, info.updated_at.to_unix)

      @seeding.set_intro(snvid, info.intro)

      source_url.add(snvid, info.source)
      count_word.add(snvid, info.word_count)
      count_crit.add(snvid, info.crit_count)
      count_list.add(snvid, info.addListTotal)

      if idx % 100 == 0
        puts "- [yousuu] <#{idx}/#{input.size}>".colorize.cyan
        save!(mode: :upds)
      end
    rescue err
      puts "- error loading [#{snvid}]: #{err}".colorize.red
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

    input.each_with_index(1) do |(snvid, voters, rating), idx|
      btitle, author = @seeding._index.get(snvid).not_nil!
      btitle, author = NvHelper.fix_nvname(btitle, author)
      next if btitle.empty? || author.empty?

      nvname = "#{btitle}\t#{author}"
      next if checked.includes?(nvname)
      checked.add(nvname)

      if authors.includes?(author) || qualified?(voters, rating)
        authors.add(author)

        bhash, existed = @seeding.upsert!(snvid)
        NvValues.set_score(bhash, voters, rating)

        origin = source_url.fval(snvid)
        NvValues.origin.add(bhash, origin) if origin && !origin.empty?

        NvValues.yousuu.add(bhash, snvid)
        NvValues.hidden.add(bhash, @seeding.hidden.fval(snvid) || "0")
      end

      if idx % 100 == 0
        puts "- [yousuu] <#{idx}/#{input.size}>".colorize.blue
        Nvinfo.save!(mode: :upds)
      end
    rescue err
      puts snvid
      puts err.backtrace
    end

    Nvinfo.save!(mode: :full)
  end

  def qualified?(voters : Int32, rating : Int32)
    return rating >= 30 if voters >= 70
    return rating >= 40 if voters >= 50
    return rating >= 50 if voters >= 30
    return rating >= 60 if voters >= 10

    rating >= 70
  end
end

worker = CV::Seeds::MapYousuu.new
worker.init! unless ARGV.includes?("-init")
worker.seed!
