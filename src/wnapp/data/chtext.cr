require "./chinfo"
require "./wnseed"

require "../../_util/chap_util"
require "../../zroot/html_parser/raw_rmchap"

class WN::Chtext
  getter wc_base : String

  WN_DIR = "var/wnapp/chtext"
  ZH_DIR = "var/zroot/wntext"

  V0_DIR = "var/texts/rgbks"

  def initialize(@seed : Wnseed, @chap : Chinfo)
    @wc_base = "#{WN_DIR}/#{seed.wn_id}/#{chap.ch_no}"
  end

  def wn_path(index : Int32, cksum = @chap.cksum)
    "#{@wc_base}-#{cksum}-#{index}.txt"
  end

  def file_exists?
    !@chap.cksum.empty? && File.file?(wn_path(0))
  end

  def get_cksum!(uname : String, _mode = 0)
    return "" if _mode < 0
    return @chap.cksum if _mode < 1 && file_exists?

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

    zh_path = "#{ZH_DIR}/#{@chap.spath}.txt"
    Dir.mkdir_p(File.dirname(zh_path))
    File.open(zh_path, "w") { |file| parts.join(file, "\n\n") }

    self.save_text!(parts, sizes, cksum)
  end

  def import_existing!
    # Log.info { "find from existing data".colorize.yellow }

    files = ["#{ZH_DIR}/#{@chap.spath}.txt"]

    if @seed.sname[0] != '!'
      spath = "#{@seed.sname}/#{@seed.wn_id}/#{@chap.ch_no}"
      files << "#{V0_DIR}/#{spath}.gbk"
      files << "#{V0_DIR}/#{spath}.txt"
    end

    files << "#{V0_DIR}/#{@chap.spath}.gbk"
    files << "#{V0_DIR}/#{@chap.spath}.txt"

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

    Dir.mkdir_p(File.dirname(@wc_base))

    parts.each_with_index do |cpart, index|
      save_path = self.wn_path(index)

      File.open(save_path, "w") do |file|
        file << parts[0]
        file << '\n' << cpart if index > 0
      end
    end

    @chap.update!(db: @seed.chap_list)
    cksum
  end

  def load_all!
    return "" if @chap.cksum.empty?
    String.build do |io|
      (@chap.sizes.size).times do |index|
        cpart = File.read(wn_path(index))
        cpart = index > 0 ? cpart.gsub(/^[^\n]+/, "") : cpart.gsub(/\n.+/, "")

        io << cpart
      rescue ex
        io << "[Có lỗi, mời liên hệ ban quản trị!]"
      end
    end
  end
end
