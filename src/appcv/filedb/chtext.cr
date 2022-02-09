require "file_utils"
require "compress/zip"

require "../../_util/ram_cache"
require "../remote/rm_text"
require "../nvchap/ch_info"

class CV::Chtext
  struct Data
    property lines = [] of String
    property utime = 0_i64

    def initialize
    end

    def initialize(@lines, @utime)
    end
  end

  CACHE = RamCache(String, self).new(1024, 6.hours)
  TEXTS = RamCache(String, Data).new(512, 3.hours)

  CHARS = 3000
  VPDIR = "var/chtexts"

  def self.load(sname : String, snvid : String, infos : ChInfo)
    CACHE.get("#{sname}/#{snvid}/#{infos.chidx}") { new(sname, snvid, infos) }
  end

  getter infos : ChInfo

  def initialize(@sname : String, @snvid : String, @infos)
    if @sname == "chivi"
      @chdir = "#{VPDIR}/#{@infos.o_sname}/#{@infos.o_snvid}"
      pgidx = (@infos.o_chidx - 1) // 128

      @h_key = "#{@infos.o_sname}/#{@infos.o_snvid}/#{@infos.o_chidx}"
    else
      @chdir = "#{VPDIR}/#{sname}/#{snvid}"
      pgidx = (@infos.chidx - 1) // 128

      @h_key = "#{@sname}/#{@snvid}/#{@infos.chidx}"
    end
    @store = "#{@chdir}/#{pgidx}.zip"
  end

  def mkdir!
    FileUtils.mkdir_p(@chdir)
  end

  NOTFOUND = Data.new([] of String, 0_i64)

  def load!(part = 0) : Data
    TEXTS.get("#{@h_key}/#{part}") do
      Compress::Zip::File.open(@store) do |zip|
        entry = zip[part_path(part)]
        lines = entry.open(&.gets_to_end).split('\n')
        utime = entry.time.to_unix
        Data.new(lines, utime)
      end
    rescue
      NOTFOUND
    end
  end

  private def part_path(part = 0)
    "#{@infos.schid}-#{part}.txt"
  end

  def fetch!(part : Int32 = 0, ttl = 10.years, mkdir = true, lbl = "1/1")
    sname = @sname == "chivi" ? @infos.o_sname : @sname
    snvid = @sname == "chivi" ? @infos.o_snvid : @snvid

    RmText.mkdir!(sname, snvid)
    remote = RmText.new(sname, snvid, @infos.schid, ttl: ttl, lbl: lbl)

    lines = remote.paras
    # special fix for 69shu, will investigate later
    lines.unshift(remote.title) unless remote.title.empty?

    save!(lines, mkdir: mkdir)
    load!(part)
  end

  def remap!
    @infos.parts = @infos.chars = 0
    title = nil

    loop do
      chdata = self.load!(@infos.parts)
      break if chdata.utime == 0

      title ||= chdata.lines[0]?

      @infos.utime = chdata.utime if @infos.utime < chdata.utime
      @infos.chars += chdata.lines.map(&.size).sum
      @infos.parts += 1
    end

    title
  end

  def save!(input : Array(String), zipping = true, mkdir = false) : Nil
    return if input.empty?
    self.mkdir! if mkdir

    title = input[0]
    @infos.chars = input.map(&.size).sum
    @infos.utime = Time.utc.to_unix

    if @infos.chars < CHARS * 1.5
      @infos.parts = 1
      return save_part!(input, 0, zipping: zipping)
    end

    parts = (@infos.chars / CHARS).round.to_i
    limit = @infos.chars // (parts < 2 ? 1 : parts)

    lines = [] of String
    count, parts = 0, 0

    input.each do |line|
      lines << line
      count += line.size
      next if count < limit

      lines.unshift(title) if parts > 0
      save_part!(lines, parts, zipping: zipping)
      parts += 1

      lines = [] of String
      count = 0
    end

    unless lines.empty?
      lines.unshift(title) if parts > 0
      save_part!(lines, parts, zipping: zipping)
      parts += 1
    end

    @infos.parts = parts
  end

  def save_part!(lines : Array(String), part = 0, zipping = true) : Nil
    file = "#{@chdir}/#{part_path(part)}"
    File.open(file, "w") { |io| lines.join(io, "\n") }

    `zip -jqm #{@store} #{file}` if zipping
    # puts "- <zh_text> [#{file}] saved.".colorize.yellow

    TEXTS.set("#{@h_key}/#{part}", Data.new(lines, @infos.utime))
  end
end
