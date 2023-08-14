require "./chinfo"
require "./wn_seed"
require "../../_util/chap_util"

class WN::Zctext
  def initialize(@seed : Wnseed, @chap : Chinfo)
  end

  def get_ztext!
    ""
  end

  def get_cksum!(uname : String, _mode = 0)
    return "" if _mode < 0
    return force_regen! if _mode > 1
    return @chap.cksum unless @chap.cksum.empty?

    # TODO: recaculate check sum
    @chap.cksum
  end

  def force_regen!
    # TODO
    ""
  end

  def import_existing!
    files = {
      "var/texts/rgbks/#{@seed.sname}/#{@seed.s_bid}/#{@chap.ch_no}.gbk",
      "var/texts/rgbks/#{@chap.spath}.gbk",
      "var/texts/rgbks/#{@seed.sname}/#{@seed.s_bid}/#{@chap.ch_no}.txt",
      "var/texts/rgbks/#{@chap.spath}.txt",
    }

    return unless file = files.find { |x| File.file?(x) }
    encoding = file.ends_with?("gbk") ? "GB18030" : "UTF-8"
    lines = File.read_lines(file, encoding: encoding).reject(&.blank?)
    lines.map! { |line| CharUtil.canon_clean(line) }

    parts, sizes, cksum = ChapUtil.split_rawtxt(lines)
  end
end
