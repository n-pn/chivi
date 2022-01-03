require "file_utils"
require "compress/zip"

require "../../_util/ram_cache"
require "../remote/rm_text"
require "../nvchap/ch_info"

class CV::Chtext
  CACHE = RamCache(String, self).new(512, 3.hours)
  CHARS = 3000
  VPDIR = "var/chtexts"

  def self.load(sname : String, snvid : String, infos : ChInfo)
    CACHE.get("#{sname}/#{snvid}/#{infos.chidx}") { new(sname, snvid, infos) }
  end

  @parts = {} of Int32 => Tuple(Array(String), Int64)

  getter infos : ChInfo
  getter title : String { infos.z_title }

  def initialize(@sname : String, @snvid : String, @infos)
    if @sname == "chivi"
      @chdir = "#{VPDIR}/#{@infos.o_sname}/#{@infos.o_snvid}"
      pgidx = (@infos.o_chidx - 1) // 128
    else
      @chdir = "#{VPDIR}/#{sname}/#{snvid}"
      pgidx = (@infos.chidx - 1) // 128
    end
    @store = "#{@chdir}/#{pgidx}.zip"
  end

  def load!(part = 0) : Tuple(Array(String), Int64)
    @parts[part] ||= read!(part)
  end

  def mkdir!
    FileUtils.mkdir_p(@chdir)
  end

  NOTFOUND = {[] of String, 0_i64}

  def read!(part = 0) : Tuple(Array(String), Int64)
    return NOTFOUND unless File.exists?(@store)

    Compress::Zip::File.open(@store) do |zip|
      return NOTFOUND unless entry = zip[part_path(part)]?

      mtime = entry.time.to_unix
      lines = entry.open(&.gets_to_end).split('\n')

      {lines, mtime}
    end
  end

  private def part_path(part = 0)
    "#{@infos.schid}-#{part}.txt"
  end

  def fetch!(part : Int32 = 0, stale = 10.years)
    if @sname == "chivi"
      RmText.mkdir!(@infos.o_sname, @infos.o_snvid)
      remote = RmText.new(@infos.o_sname, @infos.o_snvid, @infos.schid, ttl: stale)
    else
      RmText.mkdir!(@sname, @snvid)
      remote = RmText.new(@sname, @snvid, @infos.schid, ttl: stale)
    end

    lines = remote.paras
    # special fix for 69shu, will investigate later
    lines.unshift(remote.title) unless remote.title.empty?

    save!(lines)
    @parts[part]
  end

  def remap!
    @infos.parts = @infos.chars = 0

    while true
      lines, utime = self.load!(@infos.parts)
      break if utime == 0

      @title ||= lines[0]?

      @infos.utime = utime if @infos.utime < utime
      @infos.chars += lines.map(&.size).sum
      @infos.parts += 1
    end

    @title
  end

  def save!(input : Array(String), zipping = true, mkdir = false) : Nil
    return if input.empty?
    self.mkdir! if mkdir
    @title = input[0]

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
    @parts[part] = {lines, @infos.utime}
  end
end
