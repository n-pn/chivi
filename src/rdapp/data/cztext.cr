require "./chinfo"
require "compress/zip"
require "../../_util/text_util"

class RD::Cztext
  ZIP_DIR = "/2tb/zroot/ztext"
  TXT_DIR = "var/texts"

  getter? has_zip : Bool { File.exists?(@zip_path) }

  def initialize(@sroot : String)
    @tmp_path = "#{ZIP_DIR}/#{sroot.sub(/^wn|up|rm/, "")}"
    @zip_path = "#{@tmp_path}.zip"
    Dir.mkdir_p(@tmp_path)
  end

  def get_chap_text(ch_no : Int32, cksum = "")
    load_from_zip(ch_no) || load_by_cksum(ch_no, cksum)
  end

  def load_from_zip(ch_no : Int32, smode = 1)
    return unless self.has_zip?

    Compress::Zip::File.open(@zip_path) do |zip|
      entry = zip["#{ch_no}#{smode}.zh"]? || zip["#{ch_no}0.zh"]?
      entry.try(&.open(&.gets_to_end))
    end
  end

  def load_by_cksum(ch_no : Int32, cksum : String)
    return if cksum.empty?
    sbase = "#{TXT_DIR}/#{@sroot}/#{ch_no}-#{cksum}"

    String.build do |io|
      0.upto(99) do |p_idx|
        fpath = "#{sbase}-#{p_idx}.raw.txt"
        break unless File.file?(fpath)

        cbody = File.read(fpath)
        cbody = cbody.sub(/^.+\n/, "\n\n") if p_idx > 0

        io << cbody
      end
    end
  end

  def read_text_part_by_ckcsum(ch_no : Int32, cksum : String, p_idx : Int32)
    return if cksum.empty?
    fpath = "#{TXT_DIR}/#{@sroot}/#{ch_no}-#{cksum}-#{p_idx}.raw.txt"
    File.read(fpath) rescue nil
  end

  def save_text!(ch_no : Int32, ztext : String,
                 chdiv : String = "", smode : Int32 = 0,
                 zipping : Bool = true)
    fpath = "#{@tmp_path}/#{ch_no}#{smode}.zh"
    File.open(fpath, "w") { |f| f << "///" << chdiv << '\n' << ztext }
    zipping_text!(fpath) if zipping
  end

  def zipping_text!(data_path : String = @tmp_path)
    `zip -FSrjyoq '#{@zip_path}' '#{data_path}'`
    @has_zip = true if $?.success?
  end

  ###

  CHAR_LIMIT = 2048
  CHAR_UPPER = 3200

  @[AlwaysInline]
  def self.char_limit(char_count : Int32)
    char_count < CHAR_UPPER ? CHAR_UPPER : char_count // (char_count / CHAR_LIMIT).round.to_i
  end

  def self.fix_raw(input : String, title : String = "")
    lines = input.each_line.compact_map do |line|
      TextUtil.canon_clean(line) unless line.blank?
    end

    fix_raw(lines.to_a, title: title)
  end

  def self.fix_raw(lines : Array(String), title : String = "")
    lines.shift if lines[0].starts_with?("///") # remove chap div

    limit = char_limit(lines.sum(&.size))
    title = lines.shift if title.empty? # extract chap title

    cbody = String::Builder.new(title)
    count = 0

    lines.each do |line|
      cbody << '\n' if count == 0
      cbody << '\n' << line

      count &+= line.size
      count = 0 if count > limit
    end

    cbody.to_s
  end
end
