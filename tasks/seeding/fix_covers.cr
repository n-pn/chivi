require "file_utils"
require "../../src/filedb/nvinfo"

class CV::Seeds::FixCovers
  getter source : ValueMap = NvValues.source

  DIR = "_db/bcover"
  ::FileUtils.mkdir_p("#{DIR}/_chivi")

  def fix!(redo : Bool = false)
    checked = Set(String).new

    @source.data.each_with_index(1) do |(b_hash, values), idx|
      checked.add(b_hash)
      next unless edo || !NvValues.bcover.has_key?(b_hash)

      covers = {} of String => String

      if y_nvid = NvValues.yousuu.fval(b_hash)
        covers["yousuu"] = y_nvid
      end

      values.each do |entry|
        s_name, s_nvid = entry.split("/")
        covers[s_name] = s_nvid
      end

      bcover = nil
      mwidth = 0

      covers.each do |s_name, s_nvid|
        next unless cover_file = cover_path(s_name, s_nvid)
        cover_width = image_width(cover_file)

        if cover_width > mwidth
          bcover = cover_file
          mwidth = cover_width
        end
      end

      next unless bcover && NvValues.bcover.add(b_hash, bcover.sub("#{DIR}/", ""))

      out_file = "#{DIR}/_chivi/#{b_hash}.webp"
      convert_img(bcover, out_file)

      if idx % 20 == 0
        puts "- [chseed_covers] <#{idx}/#{@chseed.size}>".colorize.blue
        save!(mode: :upds)
      end
    end

    yousuu = NvValues.yousuu.data
    yousuu.each_with_index(1) do |(b_hash, values), idx|
      next if checked.includes?(b_hash)
      next unless redo || !NvValues.bcover.has_key?(b_hash)

      next unless cover_file = cover_path("yousuu", values.first)
      next if image_width(cover_file) < 10
      NvValues.bcover.add(b_hash, cover_file.sub("#{DIR}/", ""))

      if idx % 20 == 0
        puts "- [yousuu_covers] <#{idx}/#{yousuu.size}>".colorize.blue
        save!(mode: :upds)
      end
    end

    save!(mode: :full)
  end

  def cover_path(s_name : String, s_nvid : String) : String?
    {"html", "jpg.gz", ".pc", ".apple", ".ascii"}.each do |ext|
      file = "#{DIR}/#{s_name}/#{s_nvid}.#{ext}"
      return if File.exists?(file)
    end

    {"gif", "png", "tiff", "jpg"}.each do |ext|
      file = "#{DIR}/#{s_name}/#{s_nvid}.#{ext}"
      return file if File.exists?(file)
    end
  end

  private def image_width(file : String) : Int32
    return 0 if File.size(file) < 100
    return 9999 if file.ends_with?(".gif")
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
