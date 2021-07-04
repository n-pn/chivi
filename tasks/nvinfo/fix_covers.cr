require "../shared/seed_util"

class CV::FixCovers
  INP_DIR = "_db/bcover"
  OUT_DIR = "_db/bcover/_webps"

  ::FileUtils.mkdir_p(OUT_DIR)

  def fix!(redo : Bool = false)
    total, index = Cvbook.query.count, 0
    query = Cvbook.query.with_ysbooks.with_zhbooks.order_by(weight: :desc)
    query.each_with_cursor(10) do |cvbook|
      index += 1

      if index % 20 == 0
        puts "- [fix_covers] <#{index}/#{total}>".colorize.blue
        @widths.each_value { |map| map.save!(clean: false) }
      end

      covers = [] of Tuple(String, String)
      covers << {"chivi", cvbook.bhash}

      cvbook.ysbooks.each { |x| covers << {"yousuu", x.id.to_s} }
      cvbook.zhbooks.each { |x| covers << {x.sname, x.snvid} }

      max_width, out_cover = 0, nil
      out_sname, out_snvid = nil, nil

      covers.each do |sname, snvid|
        next unless cover_file = cover_path(sname, snvid)

        unless cover_width = width_map(sname).ival(cover_file)
          cover_width = image_width(cover_file)

          if mtime = File.info?(cover_file).try(&.modification_time)
            values = [cover_width, mtime.to_unix]
            width_map(sname).set!(cover_file, values.map(&.to_s))
          end
        end

        if cover_width > max_width
          max_width, out_cover = cover_width, cover_file
          out_sname, out_snvid = sname, snvid
        end
      end

      next unless out_cover && out_sname && out_snvid
      # puts "  cover chosen: #{out_cover}"

      out_webp = "#{out_sname}-#{out_snvid}.webp"
      cvbook.tap(&.bcover = out_webp).save! unless cvbook.bcover == out_webp

      webp_path = "#{OUT_DIR}/#{out_webp}"
      next if File.exists?(webp_path)

      case out_cover
      when .ends_with?(".webp")
        File.copy(out_cover, webp_path)
      when .ends_with?(".gif")
        `gif2webp "#{out_cover}" -o "#{webp_path}"`
      else
        `convert "#{out_cover}" -resize "320x>" "#{webp_path}"`
      end
    end

    @widths.each_value { |map| map.save!(clean: false) }
  end

  @widths = {} of String => ValueMap

  private def width_map(sname : String)
    @widths[sname] ||= ValueMap.new("#{INP_DIR}/_index/#{sname}.tsv")
  end

  # next unless cover_file = cover_path(snam
  def cover_path(sname : String, snvid : String) : String?
    {"webp", "gif", "png", "tiff"}.each do |ext|
      file = image_path(sname, snvid, ext)
      return file if File.exists?(file)
    end

    {"html", "pc", "apple", "ascii"}.each do |ext|
      file = image_path(sname, snvid, ext)
      return if File.exists?(file)
    end

    file = image_path(sname, snvid, "jpg")
    return file if File.exists?(file)
  end

  private def image_path(sname, snvid, ext)
    "#{INP_DIR}/#{sname}/#{snvid}.#{ext}"
  end

  def image_width(fname : String)
    if fname.ends_with?(".gif")
      return case fname
      when .includes?("chivi")  then 20000
      when .includes?("yousuu") then 10000
      when .includes?("jx_la")  then 0
      else                           400
      end
    end

    return 0 if File.size(fname) < 100
    `identify -format '%w %h' "#{fname}"`.split(" ").first.to_i? || 0
  rescue
    0
  end
end

worker = CV::FixCovers.new
worker.fix!(redo: ARGV.includes?("redo"))
