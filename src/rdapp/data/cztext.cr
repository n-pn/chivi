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

  def get_chap_text(ch_no : Int32, smode : Int32 = 1)
    return unless self.has_zip?

    Compress::Zip::File.open(@zip_path) do |zip|
      entry = zip["#{ch_no}#{smode}.zh"]? || zip["#{ch_no}0.zh"]?
      entry.try(&.open(&.gets_to_end))
    end
  end

  def save_text!(ch_no : Int32, ztext : String,
                 chdiv : String = "", smode : Int32 = 0,
                 zipping : Bool = true)
    fpath = "#{@tmp_path}/#{ch_no}#{smode}.zh"
    File.open(fpath, "w") { |f| f << "///" << chdiv << '\n' << ztext }
    zipping_text!(fpath) if zipping
  end

  def zipping_text!(data_path : String = @tmp_path)
    `zip -rjyoq '#{@zip_path}' '#{data_path}'`
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
