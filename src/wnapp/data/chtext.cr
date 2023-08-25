require "./chinfo"
require "./wnseed"

require "../../_util/chap_util"
require "../../zroot/html_parser/raw_rmchap"

class WN::Chtext
  getter wc_base : String

  WN_DIR = "var/wnapp/chtext"
  ZH_DIR = "var/zroot/wntext"

  V0_DIR = "var/texts/rgbks"

  def initialize(@seed : Wnsterm, @chap : Chinfo)
    @wc_base = "#{WN_DIR}/#{seed.wn_id}/#{chap.ch_no}"
  end

  def wn_path(p_idx : Int32, cksum : String = @chap.cksum)
    "#{@wc_base}-#{cksum}-#{p_idx}.txt"
  end

  def zh_path(cksum : String = @chap.cksum)
    spath = @chap.spath
    spath = "#{@seed.sname}/#{@seed.s_bid}/#{@chap.ch_no}" if spath.empty?
    "#{ZH_DIR}/#{spath}-#{cksum}-#{@chap.ch_no}.txt"
  end

  def file_exists?
    !@chap.cksum.empty? && File.file?(wn_path(p_idx: 0))
  end

  def get_cksum!(uname : String = "", _mode = 0)
    return "" if _mode < 0
    return @chap.cksum if _mode < 2 && file_exists?

    if _mode > 1
      load_from_remote!(uname: uname, force: true) || import_existing! || @chap.cksum
    else
      import_existing! || load_from_remote!(uname: uname, force: false) || @chap.cksum
    end
  end

  def save_from_upload!(ztext : String, uname : String = "")
    @chap.uname = uname
    @chap.mtime = Time.utc.to_unix

    self.save_text!(ztext: ztext)
  end

  def load_from_remote!(uname : String, force : Bool = false)
    rlink = @chap.rlink
    return if rlink.empty?

    stale = Time.utc - (force ? 1.minutes : 20.years)
    title, paras = ZR::RawRmchap.from_link(rlink, stale: stale).parse_page!

    @chap.uname = uname
    @chap.mtime = Time.utc.to_unix

    self.save_text!(paras: paras, title: title)
  end

  def import_existing!
    # Log.info { "find from existing data".colorize.yellow }

    files = [self.zh_path]

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
    self.save_text!(ztext: File.read(file, encoding: encoding, invalid: :skip))
  end

  def save_text!(ztext : String) : String
    lines = [] of String

    ztext.each_line do |line|
      lines << TextUtil.canon_clean(line) unless line.blank?
    end

    self.save_text!(paras: lines)
  end

  def save_text!(paras : Array(String), title : String = paras.shift) : String
    parts, sizes, cksum = ChapUtil.split_rawtxt(lines: paras, title: title)
    save_text!(parts, cksum: cksum, sizes: sizes)
  end

  def save_text!(parts : Array(String),
                 cksum : UInt32,
                 sizes : Array(Int32) = parts.map(&.size)) : String
    @chap.cksum = ChapUtil.cksum_to_s(cksum)
    @chap.sizes = sizes.map(&.to_s).join(' ')

    self.save_backup!(parts)
    # return @chap.cksum if File.file?(self.wn_path(0))

    # Dir.mkdir_p(File.dirname(@wc_base))

    parts.each_with_index do |cpart, index|
      save_path = self.wn_path(index)

      File.open(save_path, "w") do |file|
        file << parts[0]
        file << '\n' << cpart if index > 0
      end
    end

    @chap.upsert!(db: @seed.chap_list)
    @chap.cksum
  end

  private def save_backup!(parts : Array(String), cksum : String = @chap.cksum)
    # Log.info { "save backup!".colorize.yellow }

    zh_path = self.zh_path(cksum)
    return if File.file?(zh_path)

    dirname = File.dirname(zh_path)
    Dir.mkdir_p(dirname)

    # TODO: track activity?

    File.open(zh_path, "w") { |file| parts.join(file, "\n\n") }
  end

  def load_all!
    return "" if @chap.cksum.empty?

    String.build do |io|
      @chap.sizes.each_index do |p_idx|
        cpart = load_part!(p_idx)
        cpart = p_idx > 0 ? cpart.gsub(/^[^\n]+/, "") : cpart.gsub(/\n.+/, "")
        io << cpart
      rescue ex
        io << "[[Thiếu nội dung, mời liên hệ ban quản trị!]]"
      end
    end
  end

  def load_part!(p_idx : Int32 = 1)
    File.read(self.wn_path(p_idx))
  end
end
