require "./chinfo"
require "./wnstem"

class WN::Chtext
  getter wc_base : String

  TXT_DIR = "var/texts"
  BAK_DIR = "var/zroot/wntext"
  OLD_DIR = "/2tb/var.chivi/_prev/ztext"

  def initialize(@stem : Wnstem, @chap : Chinfo)
    @wc_base = gen_wc_base(stem, chap.ch_no)
    chap.spath = "#{stem.sname}/#{stem.s_bid}/#{chap.ch_no}" if chap.spath.empty?
  end

  def gen_wc_base(stem : Wnstem, ch_no : Int32) : String
    case stem.sname[0]
    when '~' then "#{TXT_DIR}/wn#{stem.sname}/#{stem.wn_id}/#{ch_no}"
    when '!' then "#{TXT_DIR}/rm#{stem.sname}/#{stem.s_bid}/#{ch_no}"
    else          raise "unsupported kind!"
    end
  end

  def raw_path(p_idx : Int32, cksum : String = @chap.cksum)
    "#{@wc_base}-#{cksum}-#{p_idx}.raw.txt"
  end

  def ext_path(p_idx : Int32, ext : String)
    "#{@wc_base}-#{@chap.cksum}-#{p_idx}.#{ext}"
  end

  def bak_path(cksum : String = @chap.cksum)
    "#{BAK_DIR}/#{@chap.spath}-#{cksum}-#{@chap.ch_no}.txt"
  end

  def file_exists?
    !@chap.cksum.empty? && File.file?(raw_path(p_idx: @chap.psize))
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
    title, paras = RawRmchap.from_link(rlink, stale: stale).parse_page!

    @chap.uname = uname
    @chap.mtime = Time.utc.to_unix

    Dir.mkdir_p(File.dirname(@wc_base))
    self.save_text!(paras: paras, title: title)
  rescue
    nil
  end

  def import_existing! : String?
    # Log.info { "find from existing data".colorize.yellow }

    files = [self.bak_path]

    if @stem.sname[0] != '!'
      spath = "#{@stem.sname}/#{@stem.wn_id}/#{@chap.ch_no}"
      files << "#{OLD_DIR}/#{spath}.gbk"
      files << "#{OLD_DIR}/#{spath}.txt"
    end

    files << "#{OLD_DIR}/#{@chap.spath}.gbk"
    files << "#{OLD_DIR}/#{@chap.spath}.txt"

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

    parts.each_with_index do |cpart, index|
      save_path = self.raw_path(p_idx: index)

      File.open(save_path, "w") do |file|
        file << parts[0]
        file << '\n' << cpart if index > 0
      end
    end

    self.save_backup!(parts)

    @chap.upsert!(db: @stem.chap_list)
    @chap.cksum
  end

  private def save_backup!(parts : Array(String), cksum : String = @chap.cksum)
    # Log.info { "save backup!".colorize.yellow }

    bak_path = self.bak_path(cksum)
    return if File.file?(bak_path)

    dirname = File.dirname(bak_path)
    Dir.mkdir_p(dirname)

    # TODO: track activity?

    File.open(bak_path, "w") { |file| parts.join(file, "\n\n") }
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
    File.read(self.raw_path(p_idx))
  end

  def load_raw!(p_idx : Int32 = 1)
    File.read_lines(self.raw_path(p_idx), chomp: true)
  end

  # def load_part_from_copus(p_idx : Int32 = 1)
  #   zorig = "#{@chap.ch_no}-#{@chap.cksum}-#{p_idx}"

  #   @corpus.get_texts_by_zorig(zorig) || begin
  #     lines = File.read(self.raw_path(p_idx))
  #     u8_ids, _ = @corpus.add_part!(zorig)
  #     {u8_ids, lines}
  #   end
  # end

end
