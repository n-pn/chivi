require "file_utils"

require "../../src/source/ys_nvinfo"
require "./_seeding.cr"

class CV::MapYousuu
  getter source_url : ValueMap { ValueMap.new(@meta.map_path("source_url")) }
  getter count_word : ValueMap { ValueMap.new(@meta.map_path("count_word")) }
  getter count_crit : ValueMap { ValueMap.new(@meta.map_path("count_crit")) }
  getter count_list : ValueMap { ValueMap.new(@meta.map_path("count_list")) }

  def initialize
    @meta = InfoSeed.new("yousuu")
  end

  def init!
    input = Dir.glob("_db/yousuu/.cache/infos/*.json").sort_by do |file|
      File.basename(file, ".json").to_i
    end

    puts "- Input: #{input.size} files.".colorize.cyan

    input.each_with_index(1) do |file, idx|
      snvid = File.basename(file, ".json")
      atime = InfoSeed.get_atime(file) || 0_i64
      next if @meta._index.ival_64(snvid) >= atime

      next unless info = YsNvinfo.load(file)
      @meta._index.set!(snvid, [atime.to_s, info.title, info.author])

      @meta.genres.set!(snvid, [info.genre].concat(info.tags_fixed))
      @meta.bcover.set!(snvid, info.cover_fixed)

      @meta.status.set!(snvid, info.status)
      @meta.hidden.set!(snvid, info.shielded ? "1" : "0")

      @meta.rating.set!(snvid, [info.voters.to_s, info.rating.to_s])
      @meta.update.set!(snvid, info.updated_at.to_unix)

      @meta.set_intro(snvid, info.intro)

      source_url.set!(snvid, info.source)
      count_word.set!(snvid, info.word_count)
      count_crit.set!(snvid, info.crit_count)
      count_list.set!(snvid, info.addListTotal)

      if idx % 100 == 0
        puts "- [yousuu] <#{idx}/#{input.size}>".colorize.cyan
        save_meta!(clean: false)
      end
    rescue err
      puts "- error loading [#{snvid}]: #{err}".colorize.red
    end

    save_meta!(clean: true)
  end

  private def save_meta!(clean : Bool = false)
    @meta.save!(clean: clean)

    @source_url.try(&.save!(clean: clean))
    @count_word.try(&.save!(clean: clean))
    @count_crit.try(&.save!(clean: clean))
    @count_list.try(&.save!(clean: clean))
  end

  def seed!(mode : Symbol = :best)
    checked = Set(String).new

    input = @meta.rating.data.to_a.map { |k, v| {k, v[0].to_i, v[1].to_i} }
    input.sort_by! { |a, b, c| -b }

    input.each_with_index(1) do |(snvid, voters, rating), idx|
      _atime, btitle, author = @meta._index.get(snvid).not_nil!
      btitle, author = NvUtils.fix_labels(btitle, author)
      next if btitle.empty? || author.empty?

      nvname = "#{btitle}\t#{author}"
      next if checked.includes?(nvname)
      checked.add(nvname)

      if qualified?(voters, rating) || InfoSeed.qualified_author?(author)
        InfoSeed.update_author_score(author, voters * rating)

        nvinfo, exists = @meta.upsert!(snvid)
        nvinfo.set_scores(voters, rating)

        nvinfo.set_yousuu(snvid)
        nvinfo.set_origin(source_url.fval(snvid) || "")
        nvinfo.set_hidden(@meta.hidden.fval(snvid) || "0")

        nvinfo.save!(clean: false)
      end

      if idx % 100 == 0
        puts "- [yousuu] <#{idx}/#{input.size}>".colorize.blue
        NvIndex.save!(clean: false)
      end
    rescue err
      puts snvid
      puts err.backtrace
    end

    NvIndex.save!(clean: true)
    InfoSeed.author_scores.save!(clean: true)
  end

  def qualified?(voters : Int32, rating : Int32)
    return rating >= 30 if voters >= 70
    return rating >= 40 if voters >= 50
    return rating >= 50 if voters >= 30
    return rating >= 60 if voters >= 10
    rating >= 70 && voters >= 5
  end
end

worker = CV::MapYousuu.new
worker.init!
worker.seed!
