require "file_utils"

require "../../src/seeds/ys_nvinfo"
require "./_seeding.cr"

class CV::MapYousuu
  getter source_url : ValueMap { ValueMap.new(@meta.map_path("source_url")) }
  getter count_word : ValueMap { ValueMap.new(@meta.map_path("count_word")) }
  getter count_crit : ValueMap { ValueMap.new(@meta.map_path("count_crit")) }
  getter count_list : ValueMap { ValueMap.new(@meta.map_path("count_list")) }

  def initialize
    @meta = Seeding.new("yousuu")
  end

  def init!
    input = Dir.glob("_db/yousuu/.cache/infos/*.json").sort_by do |file|
      File.basename(file, ".json").to_i
    end

    puts "- Input: #{input.size} files.".colorize.cyan

    input.each_with_index(1) do |file, idx|
      snvid = File.basename(file, ".json")
      atime = Seeding.get_atime(file) || 0_i64
      next if @meta._index.ival_64(snvid) >= atime

      next unless info = YsNvInfo.load(file)
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
      next if btitle.empty? || author.empty?

      author = NvAuthor.fix_zh_name(author, btitle)
      btitle = NvBtitle.fix_zh_name(btitle, author)

      blabel = "#{btitle}  #{author}"
      next if checked.includes?(blabel)
      checked.add(blabel)

      if qualified?(voters, rating) || NvAuthor.exists?(author)
        bhash, _ = @meta.upsert!(snvid, fixed: true)
        NvOrders.set_scores!(bhash, voters, rating)

        NvFields.yousuu.set!(bhash, snvid)
        NvFields.origin.set!(bhash, source_url.fval(snvid) || "")
        NvFields.hidden.set!(bhash, @meta.hidden.fval(snvid) || "0")
      end

      if idx % 100 == 0
        puts "- [map_yousuu] <#{idx}/#{input.size}>".colorize.blue
        NvInfo.save!(clean: false)
      end
    rescue err
      puts snvid
      puts err.backtrace
    end

    NvInfo.save!(clean: false)
  end

  def qualified?(voters : Int32, rating : Int32)
    return rating >= 30 if voters >= 70
    return rating >= 40 if voters >= 50
    return rating >= 50 if voters >= 30
    return rating >= 60 if voters >= 10

    rating >= 65 && voters >= 5
  end
end

worker = CV::MapYousuu.new
worker.init!
worker.seed!
