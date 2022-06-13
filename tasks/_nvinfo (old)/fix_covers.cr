require "../shared/seed_util"

class CV::FixCovers
  INP_DIR = "_db/bcover"
  OUT_DIR = "priv/static/covers"

  ::FileUtils.mkdir_p(OUT_DIR)

  def out_path(path)
    "#{OUT_DIR}/#{path}"
  end

  def set!(redo : Bool = false)
    total, index = Nvinfo.query.count, 0
    query = Nvinfo.query.order_by(weight: :desc)
    query.each_with_cursor(20) do |nvinfo|
      index += 1

      if index % 100 == 0
        puts "- [fix_covers] <#{index}/#{total}>".colorize.blue
        @@widths.each_value { |map| map.save!(clean: false) }
      end

      fix_cover!(nvinfo)
    end

    @@widths.each_value { |map| map.save!(clean: false) }
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fix_cover!(nvinfo, redo = false)
    unless redo || nvinfo.bcover.empty?
      return File.exists?(out_path(nvinfo.bcover))
    end

    covers = [] of Tuple(String, String)
    covers << {"=base", nvinfo.bhash}

    covers << {"yousuu", nvinfo.ysbook_id.to_s} if nvinfo.ysbook_id > 0
    nvinfo.nvseeds.to_a.sort_by(&.zseed).each { |x| covers << {x.sname, x.snvid} }

    max_width, out_cover = 0, nil
    out_sname, out_snvid = nil, nil

    unless redo
      covers.each do |sname, snvid|
        out_webp = "#{sname}-#{snvid}.webp"
        next unless File.exists? out_path(out_webp)

        unless nvinfo.bcover == out_webp
          nvinfo.tap(&.bcover = out_webp).save!
        end

        return puts "- reuse existing!"
      end
    end

    covers.each do |sname, snvid|
      next unless cover_file = cover_path(sname, snvid)

      if File.exists? out_path("#{sname}-#{snvid}.webp")
        out_cover, out_sname, out_snvid = cover_file, sname, snvid
        break
      end

      unless cover_width = width_map(sname).fval(cover_file).try(&.to_i)
        cover_width = image_width(cover_file)

        if mtime = File.info?(cover_file).try(&.modification_time)
          values = [cover_width, mtime.to_unix]
          width_map(sname).set!(cover_file, values.map(&.to_s))
        end
      end

      if cover_width > max_width
        max_width, out_cover = cover_width, cover_file
        out_sname, out_snvid = sname, snvid
        break if max_width >= 360
      end
    end

    unless out_cover && out_sname && out_snvid
      return puts "no cover available for #{nvinfo.vname}!"
    end

    out_webp = "#{out_sname}-#{out_snvid}.webp"
    nvinfo.tap(&.bcover = out_webp).save! unless nvinfo.bcover == out_webp

    webp_path = out_path(out_webp)
    return if File.exists?(webp_path) || !File.exists?(out_cover)

    case out_cover
    when .ends_with?(".gif")
      gif_to_webp(out_cover, webp_path)
    else
      width = max_width > 360 ? 360 : max_width
      to_webp(out_cover, webp_path, width: width)
    end

    return if File.exists?(webp_path)

    puts "#{webp_path} not generated from #{out_cover}:#{max_width}"
    File.delete(out_cover)
  end

  private def gif_to_webp(inp_file, out_file)
    `gif2webp -quiet "#{inp_file}" -o "#{out_file}"`
  end

  private def to_webp(inp_file, out_file, width = 360)
    if width > 360
      `cwebp -quiet -q 100 -resize #{width} 0 -mt "#{inp_file}" -o "#{out_file}"`
    else
      `cwebp -quiet -q 100 -mt "#{inp_file}" -o "#{out_file}"`
    end

    return if File.exists?(out_file)
    `convert #{inp_file} -quality 50 -define webp:lossless=true -resize "#{width}x>" #{out_file}`
  end

  @@widths = {} of String => TsvStore

  private def width_map(sname : String)
    @@widths[sname] ||= TsvStore.new("var/nvinfos/#{sname}/bcover.tsv")
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

    image_path(sname, snvid, "jpg")
  end

  private def image_path(sname, snvid, ext)
    "#{INP_DIR}/#{sname}/#{snvid}.#{ext}"
  end

  def image_width(fname : String)
    return gif_image_width(fname) if fname.ends_with?(".gif")
    return 0 if File.size(fname) < 1000
    `identify -format '%w %h' "#{fname}"`.split(" ").first.to_i? || 0
  rescue
    0
  end

  def gif_image_width(fname : String)
    case fname
    when .includes?("=base")  then 360
    when .includes?("yousuu") then 360
    when .includes?("jx_la")  then 0
    else                           360
    end
  end
end

worker = CV::FixCovers.new
worker.set!(redo: ARGV.includes?("redo"))
