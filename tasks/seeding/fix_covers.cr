require "file_utils"
require "../../src/filedb/nvinfo"

class CV::Seeds::FixCovers
  getter chseed : ValueMap = NvFields.chseed

  DIR = "_db/bcover"
  ::FileUtils.mkdir_p("#{DIR}/_chivi")

  def fix!(mode : Symbol = :fast)
    checked = Set(String).new

    @chseed.data.each_with_index do |(bhash, seeds), idx|
      checked.add(bhash)
      next if mode == :fast && NvFields.bcover.has_key?(bhash)

      covers = {} of String => String

      if ybid = NvFields.yousuu.fval(bhash)
        covers["yousuu"] = ybid
      end

      seeds.each do |chseed|
        seed, sbid = chseed.split("/")
        covers[seed] = sbid
      end

      bcover = nil
      mwidth = 0

      covers.each do |seed, sbid|
        next unless cover_file = cover_path(seed, sbid)
        cover_width = image_width(cover_file)

        if cover_width > mwidth
          bcover = cover_file
          mwidth = cover_width
        end
      end

      next unless bcover && NvFields.bcover.add(bhash, bcover.sub("#{DIR}/", ""))

      out_file = "#{DIR}/_chivi/#{bhash}.webp"
      convert_img(bcover, out_file)

      if idx % 20 == 19
        puts "- [chseed_covers] <#{idx + 1}/#{@chseed.size}>".colorize.blue
        save!(mode: :upds)
      end
    end

    yousuu = NvFields.yousuu.data
    yousuu.each_with_index do |(bhash, array), idx|
      next if checked.includes?(bhash)
      next if mode == :fast && NvFields.bcover.has_key?(bhash)

      next unless cover_file = cover_path("yousuu", array.first)
      next if image_width(cover_file) < 10
      NvFields.bcover.add(bhash, cover_file.sub("#{DIR}/", ""))

      if idx % 20 == 19
        puts "- [yousuu_covers] <#{idx + 1}/#{yousuu.size}>".colorize.blue
        save!(mode: :upds)
      end
    end

    save!(mode: :full)
  end

  def cover_path(seed : String, sbid : String) : String?
    {"html", "jpg.gz", ".pc", ".apple", ".ascii"}.each do |ext|
      file = "#{DIR}/#{seed}/#{sbid}.#{ext}"
      return if File.exists?(file)
    end

    {"gif", "png", "tiff", "jpg"}.each do |ext|
      file = "#{DIR}/#{seed}/#{sbid}.#{ext}"
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
    NvFields.bcover.save!(mode: mode)
  end
end

worker = CV::Seeds::FixCovers.new
worker.fix!(ARGV.includes?("full") ? :full : :fast)
