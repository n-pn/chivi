require "./chinfo"
require "./wn_seed"
require "../../_util/chap_util"

class WN::Zctext
  getter cbase : String

  def initialize(@seed : Wnseed, @chap : Chinfo)
    @cbase = "#{seed.sname}/#{seed.s_bid}/#{chap.ch_no}"
  end

  def get_ztext!
    ""
  end

  def get_cksum!(uname : String, _mode = 0)
    return "" if _mode < 0
    return force_regen! if _mode > 1
    return @chap.cksum unless @chap.cksum.empty?

    # TODO: fetch from remote
    import_existing! || @chap.cksum
  end

  def force_regen!
    # TODO
    ""
  end

  def import_existing!
    Log.info { "find from existing data".colorize.yellow }

    files = {
      "var/texts/rgbks/#{@seed.sname}/#{@seed.s_bid}/#{@chap.ch_no}.gbk",
      "var/texts/rgbks/#{@chap.spath}.gbk",
      "var/texts/rgbks/#{@seed.sname}/#{@seed.s_bid}/#{@chap.ch_no}.txt",
      "var/texts/rgbks/#{@chap.spath}.txt",
    }

    return unless file = files.find { |x| File.file?(x) }
    Log.info { "found: #{file}".colorize.green }

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
      next if index == 0
      File.open(self.text_path(index), "w") { |f| f << parts[0] << '\n' << cpart }
    end

    @chap.update!(db: @seed.chap_list)
    cksum
  end

  DIR = "var/zroot/wntext"

  def text_path(index : Int32)
    "#{DIR}/#{@cbase}_#{index}-#{@chap.cksum}.txt"
  end
end
