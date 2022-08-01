require "file_utils"
require "compress/zip"

require "../tools/r2_client"
require "../remote/remote_text"

require "./ch_info"
require "./ch_util"

class CV::ChText
  DIR = "var/chtexts"

  getter chinfo : ChInfo

  def initialize(@sname : String, @snvid : String, @chinfo)
    if proxy = @chinfo.proxy
      @sname = proxy.sname
      @snvid = proxy.snvid
      chidx = proxy.chidx
    else
      chidx = @chinfo.chidx
    end

    dir = "#{DIR}/#{@sname}/#{@snvid}"

    pgidx = (chidx &- 1) // 128
    @chdir = "#{dir}/#{pgidx}"
    @store = "#{dir}/#{pgidx}.zip"
  end

  record Data, lines = [] of String, utime : Int64 = 0_i64
  EMPTY = Data.new

  def load!(part = 0) : Data
    fetch_zip unless File.exists?(@store)

    Compress::Zip::File.open(@store) do |zip|
      if entry = zip[part_path(part)]?
        lines = entry.open(&.gets_to_end).split('\n')
        Data.new(lines, entry.time.to_unix)
      else
        EMPTY
      end
    end
  rescue
    EMPTY
  end

  def fetch_zip : Bool
    tab_file = @store.sub(".zip", ".tab")

    if File.exists?(tab_file)
      return R2Client.download(@store.sub("var/chtexts", "texts"), @store)
    end

    return false unless @sname == "jx_la"
    remote_path = @store.sub(/^var/, "s3://chivi-bak")

    `aws s3 cp #{remote_path} #{@store}`
    $?.success?
  end

  def exists?
    return false unless File.exists?(@store)
    Compress::Zip::File.open(@store) { |zip| !!zip[part_path(0)]? }
  end

  def fetch!(part : Int32 = 0, ttl = 10.years, lbl = "1/1")
    remote = RemoteText.new(@sname, @snvid, @chinfo.schid, ttl: ttl, lbl: lbl)

    lines = remote.paras
    # TODO: check for empty title in parser
    lines.unshift(remote.title) unless remote.title.empty?

    save!(lines)
    load!(part)
  end

  def remap! : String
    stats = @chinfo.stats

    stats.chars = 0_i16
    stats.parts = 0_i8

    title = nil

    loop do
      chdata = self.load!(stats.parts)
      break if chdata.utime == 0

      title ||= chdata.lines[0]?

      stats.utime = chdata.utime if stats.utime < chdata.utime
      stats.chars += chdata.lines.sum(&.size).to_i16
      stats.parts += 1_i8
    end

    title || ""
  end

  def save!(input : Array(String), zipping = true, mkdir = true) : Nil
    return if input.empty?
    stats = @chinfo.stats

    stats.utime = Time.utc.to_unix
    stats.chars, chaps = ChUtil.split_parts(input)
    stats.parts = chaps.size.to_i8

    FileUtils.mkdir_p(@chdir) if mkdir

    chaps.each_with_index do |text, part|
      File.write("#{@chdir}/#{part_path(part)}", text)
    end

    `zip --include=\\*.txt -rjmq "#{@store}" "#{@chdir}"` if zipping
  end

  private def part_path(part = 0)
    "#{@chinfo.schid}-#{part}.txt"
  end
end
