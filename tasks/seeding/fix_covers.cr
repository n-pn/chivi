require "file_utils"
require "../../src/appcv/nv_info"

class CV::Seeds::FixCovers
  INP_DIR = "_db/bcover"
  OUT_DIR = "_db/nvdata/bcovers"

  ::FileUtils.mkdir_p(OUT_DIR)

  def fix!(redo : Bool = false)
    checked = Set(String).new

    bhashes = NvFields.bhashes
    bhashes.each_with_index(1) do |bhash, idx|
      if idx % 20 == 0
        puts "- [fix_covers] <#{idx}/#{bhashes.size}>".colorize.blue

        WIDTHS.each_value { |map| map.save!(clean: false) }
        NvFields.bcover.save!(clean: false)
      end

      next unless redo || !NvFields.bcover.has_key?(bhash)
      covers = {} of String => String

      NvFields.yousuu.fval(bhash).try { |ynvid| covers["yousuu"] = ynvid }

      snames = NvChseed.get_list(bhash)
      snames.each do |sname|
        covers[sname] = NvChseed.get_nvid(sname, bhash) || bhash
      end

      max_width = 0
      out_cover = nil

      covers.each do |sname, snvid|
        next unless cover_file = cover_path(sname, snvid)

        unless cover_width = width_map(sname).fval(cover_file).try(&.to_i)
          cover_width = image_width(cover_file)

          if mtime = File.info?(cover_file).try(&.modification_time)
            values = [cover_width.to_s, mtime.to_unix.to_s]
            width_map(sname).set!(cover_file, values)
          end
        end

        if cover_width > max_width
          max_width = cover_width
          out_cover = cover_file
        end
      end

      next unless out_cover

      sname = File.basename(File.dirname(out_cover))
      out_file = "#{OUT_DIR}/#{sname}-#{File.basename(out_cover)}"

      NvFields.bcover.set!(bhash, File.basename(out_file))
      FileUtils.cp(out_cover, out_file) unless File.exists?(out_file)

      unless out_file.ends_with?(".webp")
        out_webp = out_file + ".webp"
        `convert "#{out_file}" -resize "300>x" "#{out_webp}"` unless File.exists?(out_webp)
      end
    rescue err
      puts err
    end

    WIDTHS.each_value { |map| map.save!(clean: false) }
    NvFields.bcover.save!(clean: false)
  end

  WIDTHS = {} of String => ValueMap

  private def width_map(sname : String)
    WIDTHS[sname] ||= ValueMap.new("#{INP_DIR}/_index/#{sname}.tsv")
  end

  # next unless cover_file = cover_path(snam
  def cover_path(sname : String, snvid : String) : String?
    {"webp", "gif", "png", "tiff"}.each do |ext|
      file = image_path(sname, snvid, ext)
      return file if File.exists?(file)
    end

    {"html", "jpg.gz", ".pc", ".apple", ".ascii"}.each do |ext|
      file = image_path(sname, snvid, ext)
      return if File.exists?(file)
    end

    file = image_path(sname, snvid, ".jpg")
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

    `identify -format '%w %h' "#{fname}"`.split(" ").first.to_i? || 0
  rescue
    0
  end
end

worker = CV::Seeds::FixCovers.new
worker.fix!(ARGV.includes?("redo"))
