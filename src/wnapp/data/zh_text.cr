require "http/client"
require "compress/zip"

require "../../_util/text_util"
require "../../_util/zstd_util"

class WN::ZhText
  getter data : Array(String)
  getter zst_path : String

  getter? dirty = false

  def initialize(name : String, path : String)
    @zst_path = "var/chaps/texts-#{name}.txt.zst"
    @data = load_data_from_disk!(path)
  end

  def full_text : String
    @data.join("\n\n")
  end

  def text_part(part_no : Int32) : String
    String.build { |io| io << @data[0] << '\n' << @data[part_no]? }
  end

  private def load_data_from_disk!(path : String)
    case path
    when ":n/a" then [""]
    when ":404" then [""]
    when ":zst" then ZstdUtil.read_file(@zst_path).split("\n\n")
    else             load_data_from_zip!(path) || [""]
    end
  end

  ZIP_DIR = "var/chaps/texts"

  def load_data_from_zip!(path : String) : Array(String)?
    _, sname, s_bid, ch_no, s_cid, p_len = path.split(":")
    pg_no = (ch_no.to_i &- 1) // 128

    zip_path = "#{ZIP_DIR}/#{sname}/#{s_bid}/#{pg_no}.zip"

    unless File.file?(zip_path)
      return unless File.file?(zip_path.sub(".zip", ".tab"))
      return unless dl_zip_from_r2!(zip_path.sub(ZIP_DIR, "texts"), zip_path)
    end

    Compress::Zip::File.open(zip_path) do |zip|
      parts = [] of String

      limit = p_len.to_i? || 0
      limit = 30 if limit == 0

      limit.times do |_part|
        fpath = "#{s_cid}-#{_part}.txt"
        break unless ptext = zip[fpath]?.try(&.open(&.gets_to_end))

        if _part == 0
          title, ptext = ptext.split('\n', 2)
          parts << title << ptext
        else
          parts << ptext.sub(/^.\n/, "") # remove chapter title
        end
      end

      parts
    rescue
      nil
    end
  end

  private def dl_zip_from_r2!(path : String, file : String)
    HTTP::Client.get("https://cr2.chivi.app/#{path}") do |res|
      return false if res.status_code >= 300
      File.write(file, res.body_io) && true
    end
  end

  def save_text!(input : String) : Nil
    @data = input.split("\n\n")

    if @data.size < 2 # data is not pre-formatted
      @data = split_text(input)
    else # data is pre-formatted
      @data.each do |part|
        next if part.size <= UPPER
        raise "part char count exceed limit: #{part.size} (max: #{UPPER})!"
      end
    end

    raise "too many parts: #{@data.size} (max: 30)!" if @data.size > 30
    save_file!(@data)
  end

  def save_file!(parts = @data, out_file = @zst_path)
    Dir.mkdir_p(File.dirname(out_file))
    ZstdUtil.save_ctx(parts.join("\n\n"), out_file)
    @dirty = true
  end

  LIMIT = 3000
  UPPER = 4500

  private def split_text(input : String)
    c_len = TextUtil.clean_spaces(input).size
    p_len = c_len <= UPPER ? 1 : ((c_len - 1) // LIMIT) + 1

    limit = c_len // p_len
    count = 0

    lines = input.each_line
    parts = [lines.next.as(String).strip] of String

    strio = String::Builder.new

    lines.each do |line|
      line = line.strip
      next if line.empty?

      strio << '\n' if count > 0
      strio << line

      count &+= line.size
      next if count < limit

      parts << strio.to_s
      strio = String::Builder.new
      count = 0
    end

    parts << strio.to_s if count > 0
    parts
  end
end
