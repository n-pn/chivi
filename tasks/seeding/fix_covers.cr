require "file_utils"
require "../../src/filedb/nvinfo"

class CV::Seeds::FixCovers
  getter source : ValueMap = NvValues.source

  DIR = "_db/bcover"
  ::FileUtils.mkdir_p("#{DIR}/_chivi")

  def fix!(redo : Bool = false)
    checked = Set(String).new

    @source.data.each_with_index(1) do |(bhash, values), idx|
      checked.add(bhash)
      next unless redo || !NvValues.bcover.has_key?(bhash)

      covers = {} of String => String

      if y_nvid = NvValues.yousuu.fval(bhash)
        covers["yousuu"] = y_nvid
      end

      values.each do |entry|
        sname, snvid = entry.split("/")
        covers[sname] = snvid
      end

      bcover = nil
      mwidth = 0

      covers.each do |sname, snvid|
        next unless cover_file = cover_path(sname, snvid)
        cover_width = image_width(cover_file)

        if cover_width > mwidth
          bcover = cover_file
          mwidth = cover_width
        end
      end

      next unless bcover && NvValues.bcover.add(bhash, bcover.sub("#{DIR}/", ""))

      out_file = "#{DIR}/_chivi/#{bhash}.webp"
      convert_img(bcover, out_file)

      if idx % 20 == 0
        puts "- [remote_covers] <#{idx}/#{@source.size}>".colorize.blue
        save!(mode: :upds)
      end
    end

    yousuu = NvValues.yousuu.data
    yousuu.each_with_index(1) do |(bhash, values), idx|
      next if checked.includes?(bhash)
      next unless redo || !NvValues.bcover.has_key?(bhash)

      next unless cover_file = cover_path("yousuu", values.first)
      next if image_width(cover_file) < 10
      NvValues.bcover.add(bhash, cover_file.sub("#{DIR}/", ""))

      if idx % 20 == 0
        puts "- [yousuu_covers] <#{idx}/#{yousuu.size}>".colorize.blue
        save!(mode: :upds)
      end
    end

    save!(mode: :full)
  end

  def cover_path(sname : String, snvid : String) : String?
    {"html", "jpg.gz", ".pc", ".apple", ".ascii"}.each do |ext|
      file = "#{DIR}/#{sname}/#{snvid}.#{ext}"
      return if File.exists?(file)
    end

    {"gif", "png", "tiff", "jpg"}.each do |ext|
      file = "#{DIR}/#{sname}/#{snvid}.#{ext}"
      return file if File.exists?(file)
    end
  end

  private def image_width(file : String) : Int32
    return 0 if File.size(file) < 100

    if file.ends_with?(".gif")
      case file
      when .includes?("jx_la")  then 0
      when .includes?("yousuu") then 9999
      else                           400
      end
    end

    `identify -format '%w %h' "#{file}"`.split(" ").first.to_i? || 0
  rescue
    0
  end

  private def convert_img(inp_file : String, out_file : String)
    `convert "#{inp_file}" -resize "300>x" "#{out_file}"`
  rescue err
    puts err
  end

  def save!(mode : Symbol = :full)
    NvValues.bcover.save!(mode: mode)
  end
end

worker = CV::Seeds::FixCovers.new
worker.fix!(ARGV.includes?("redo"))
