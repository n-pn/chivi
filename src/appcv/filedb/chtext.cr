require "file_utils"
require "compress/zip"

require "../../_util/ram_cache"
require "../remote/rm_text"
require "../nvchap/ch_info"

class CV::Chtext
  record Data, lines = [] of String, utime : Int64 = 0_i64
  NOTFOUND = Data.new

  CACHE = RamCache(String, self).new(1024, 6.hours)
  TEXTS = RamCache(String, Data).new(512, 3.hours)

  VPDIR = "var/chtexts"

  def self.load(sname : String, snvid : String, chinfo : ChInfo)
    CACHE.get("#{sname}/#{snvid}/#{chinfo.chidx}") { new(sname, snvid, chinfo) }
  end

  getter chinfo : ChInfo

  def initialize(@sname : String, @snvid : String, @chinfo)
    if proxy = @chinfo.proxy
      @chdir = "#{VPDIR}/#{proxy.sname}/#{proxy.snvid}"
      pgidx = (proxy.chidx - 1) // 128

      @c_key = "#{proxy.sname}/#{proxy.snvid}/#{proxy.chidx}"
    else
      @chdir = "#{VPDIR}/#{sname}/#{snvid}"
      pgidx = (@chinfo.chidx - 1) // 128

      @c_key = "#{@sname}/#{@snvid}/#{@chinfo.chidx}"
    end

    @store = "#{@chdir}/#{pgidx}.zip"
  end

  def load!(part = 0) : Data
    TEXTS.get("#{@c_key}/#{part}") do
      Compress::Zip::File.open(@store) do |zip|
        entry = zip[part_path(part)]
        lines = entry.open(&.gets_to_end).split('\n')
        Data.new(lines, entry.time.to_unix)
      end
    rescue
      NOTFOUND
    end
  end

  def fetch!(part : Int32 = 0, ttl = 10.years, mkdir = true, lbl = "1/1")
    if proxy = @chinfo.proxy
      sname, snvid = proxy.sname, proxy.snvid
    else
      sname, snvid = @sname, @snvid
    end

    RmText.mkdir!(sname, snvid) if mkdir
    remote = RmText.new(sname, snvid, @chinfo.schid, ttl: ttl, lbl: lbl)

    lines = remote.paras
    # special fix for 69shu, will investigate later
    lines.unshift(remote.title) unless remote.title.empty?

    save!(lines)
    load!(part)
  end

  def remap! : String
    stats = @chinfo.stats

    stats.parts = stats.chars = 0
    title = nil

    loop do
      chdata = self.load!(stats.parts)
      break if chdata.utime == 0

      title ||= chdata.lines[0]?

      stats.utime = chdata.utime if stats.utime < chdata.utime
      stats.chars += chdata.lines.map(&.size).sum
      stats.parts += 1
    end

    title || ""
  end

  def save!(input : Array(String), zipping = true) : Nil
    return if input.empty?
    stats = @chinfo.stats

    stats.utime = Time.utc.to_unix
    stats.chars, files = split_text!(input)
    stats.parts = files.size

    `zip -jqm #{@store} #{files.join(' ')}` if zipping
    # puts "- <zh_text> [#{file}] saved.".colorize.yellow
  end

  LIMIT = 3000

  def split_text!(lines : Array(String))
    sizes = lines.map(&.size)
    chars = sizes.sum

    return {chars, [save_part!(lines.join('\n'))]} if chars <= LIMIT * 1.5

    parts = (chars / LIMIT).round.to_i
    limit = chars // parts

    title = lines[0]
    strio = String::Builder.new(title)

    chars, cpart = 0, 0
    files = [] of String

    lines.each_with_index do |line, idx|
      strio << "\n" << line
      chars += sizes[idx]
      next if chars < limit

      files << save_part!(strio.to_s, cpart)
      cpart += 1

      strio = String::Builder.new(title)
      chars = 0
    end

    files << save_part!(strio.to_s, cpart + 1) if chars > 0
    {chars, files}
  end

  def save_part!(input : String, part = 0) : String
    TEXTS.delete("#{@c_key}/#{part}")
    "#{@chdir}/#{part_path(part)}".tap { |fpath| File.write(fpath, input) }
  end

  private def part_path(part = 0)
    "#{@chinfo.schid}-#{part}.txt"
  end
end
