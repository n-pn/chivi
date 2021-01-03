require "file_utils"

require "../../src/filedb/nvinit/ys_info"
require "./_info_seed.cr"

class CV::Seeds::MapYousuu
  getter input = InfoSeed.new("yousuu")

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

      @input.status.add(ybid, info.status)
      @input.shield.add(ybid, info.shielded ? "1" : "0")

      @input.rating.add(ybid, [info.voters.to_s, info.rating.to_s])
      @input.update_tz.add(ybid, info.updated_at.to_unix)

      @input.set_intro(ybid, info.intro)

      source_url.add(ybid, info.source)
      count_word.add(ybid, info.word_count)
      count_crit.add(ybid, info.crit_count)
      count_list.add(ybid, info.addListTotal)

      if idx % 100 == 99
        puts "- [yousuu] <#{idx + 1}/#{input.size}>".colorize.cyan
        save!(mode: :upds)
      end
    rescue err
      puts "- error loading [#{ybid}]: #{err}".colorize.red
    end

    save!(mode: :full)
  end

  private def save!(mode : Symbol = :full)
    @input.save!(mode: mode)
    @source_url.try(&.save!(mode: mode))
    @count_word.try(&.save!(mode: mode))
    @count_crit.try(&.save!(mode: mode))
    @count_list.try(&.save!(mode: mode))
  end

  def seed!(mode : Symbol = :best)
    wl_authors = Set(String).new(Nvinfo.author.vals.map(&.first))

    output = {} of String => String

    input = @input.rating.data.to_a.map { |k, v| {k, v[0].to_i, v[1].to_i} }
    input.sort_by! { |a, b, c| -b }

    input.each_with_index do |(sbid, voters, rating), idx|
      btitle, author = @input._index.get(sbid).not_nil!
      btitle, author = Nvinfo::Utils.fix_nvname(btitle, author)

      nvname = "#{btitle}\t#{author}"
      next if output.has_key?(nvname)

      if (voters > 10 && rating >= 3.75) || wl_authors.includes?(author) || popular?(sbid)
        wl_authors.add(author)

        zh_slug, existed = @input.upsert!(sbid)
        Nvinfo.set_score(zh_slug, voters, rating)

        origin = source_url.fval(sbid)
        Nvinfo.origin.add(zh_slug, origin) if origin && !origin.empty?

        Nvinfo.yousuu.add(zh_slug, sbid)
        Nvinfo.shield.add(zh_slug, @input.shield.fval(sbid) || "0")
      end

      if idx % 100 == 99
        puts "- [yousuu] <#{idx + 1}/#{input.size}>".colorize.blue
        Nvinfo.save!(mode: :upds)
      end
    end

    Nvinfo.save!(mode: :full)
  end

  def popular?(sbid : String)
    return true if count_crit.fval(sbid).try(&.to_i.>= 5)
    return true if count_list.fval(sbid).try(&.to_i.>= 3)
    false
  end
end

worker = CV::Seeds::MapYousuu.new
worker.init! unless ARGV.includes?("-init")
worker.seed!
