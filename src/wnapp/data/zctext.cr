require "./chinfo"
require "./wn_seed"
require "../../_util/chap_util"

class WN::Zctext
  getter cbase : String

  def initialize(@seed : Wnseed, @chap : Chinfo)
    @cbase = "#{seed.sname}/#{seed.s_bid}/#{chap.ch_no}"
  end

  def get_cksum!(uname : String, _mode = 0)
    return "" if _mode < 0

    if _mode < 1 && !@chap.cksum.empty? && @chap.sizes.size > 1
      return @chap.cksum
    end

    if _mode > 1
      load_from_remote!(force: true) || import_existing! || @chap.cksum
    else
      import_existing! || load_from_remote!(force: false) || @chap.cksum
    end
  end

  def load_from_remote!(force : Bool = false)
    rlink = @chap.rlink
    return if rlink.empty?

    stale = Time.utc - (force ? 1.minutes : 20.years)
    parser = ZR::RawRmchap.from_link(rlink, stale: stale).tap(&.parse_page!)

    parts, sizes, cksum = ChapUtil.split_rawtxt(parser.paras, parser.title)
    self.save_text!(parts, sizes, cksum)
  end

  def import_existing!
    # Log.info { "find from existing data".colorize.yellow }

    files = {
      "var/texts/rgbks/#{@seed.sname}/#{@seed.s_bid}/#{@chap.ch_no}.gbk",
      "var/texts/rgbks/#{@chap.spath}.gbk",
      "var/texts/rgbks/#{@seed.sname}/#{@seed.s_bid}/#{@chap.ch_no}.txt",
      "var/texts/rgbks/#{@chap.spath}.txt",
    }

    return unless file = files.find { |x| File.file?(x) }
    # Log.info { "found: #{file}".colorize.green }

    encoding = file.ends_with?("gbk") ? "GB18030" : "UTF-8"

    lines = File.read_lines(file, encoding: encoding).reject(&.blank?)
    lines.map! { |line| TextUtil.canon_clean(line) }

    parts, sizes, cksum = ChapUtil.split_rawtxt(lines)
    self.save_text!(parts, sizes, cksum)
  end

  def save_text!(parts : Array(String), sizes : Array(Int32), cksum : UInt32) : String
    cksum = ChapUtil.cksum_to_s(cksum)

    @chap.cksum = cksum
    @chap.sizes = sizes.map(&.to_s).join(' ')

    parts.each_with_index do |cpart, index|
      save_path = self.text_path(index)

      File.open(save_path, "w") do |file|
        file << parts[0]
        file << '\n' << cpart if index > 0
      end
    end

    @chap.update!(db: @seed.chap_list)
    cksum
  end

  DIR = "var/zroot/wntext"

  def text_path(index : Int32)
    "#{DIR}/#{@cbase}_#{index}-#{@chap.cksum}.txt"
  end

  def load_all!
    return "" if @chap.cksum.empty?
    String.build do |io|
      (@chap.sizes.size).times do |index|
        cpart = File.read(text_path(index))
        cpart = index > 0 ? cpart.gsub(/^[^\n]+/, "") : cpart.gsub(/\n.+/, "")

        io << cpart
      rescue ex
        io << "[Có lỗi, mời liên hệ ban quản trị!]"
      end
    end
  end
end
