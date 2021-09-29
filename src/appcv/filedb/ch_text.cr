require "file_utils"
require "compress/zip"

require "../../libcv/mt_core"
require "../../seeds/rm_text"
require "../../cutil/ram_cache"

class CV::ChText
  CACHED = RamCache(String, self).new(512, 3.hours)

  def self.load(bname : String, sname : String, snvid : String,
                chidx : Int32, schid : String)
    CACHED.get("#{sname}/#{snvid}/#{schid}") do
      new(bname, sname, snvid, chidx, schid)
    end
  end

  PART_LIMIT = 3000

  @parts = {} of Int32 => Array(String)

  # @cv_data : String?
  # @cv_time : Time

  DIR = "db/chtexts"

  def initialize(@bname : String, @sname : String, @snvid : String,
                 @chidx : Int32, @schid : String)
    @text_dir = "#{DIR}/#{@sname}/#{@snvid}"
    @zip_file = File.join(@text_dir, "#{@chidx // 128}.zip")
  end

  def get_zh!(part : Int32 = 0, remote = false, reset = false)
    lines = load_zh!(part)

    if remote && (reset || lines.empty?)
      fetch_zh!(reset ? 3.minutes : 30.years)
      @parts[part]
    else
      lines
    end
  end

  def load_zh!(part = 0)
    Compress::Zip::File.open(@zip_file) do |zip|
      entry = zip["#{@schid}-#{part}.txt"]
      @parts[part] = entry.open(&.gets_to_end).split('\n')
    end
  ensure
    [] of String
  end

  def fetch_zh!(ttl = 10.years, mkdir = true, lbl = "1/1") : Array(String)?
    RmText.mkdir!(@sname, @snvid) if mkdir

    puller = RmText.new(@sname, @snvid, @schid, ttl: ttl, lbl: lbl)
    save_zh!([puller.title].concat(puller.paras))
  rescue err
    puts "- Fetch zh_text error: #{err}".colorize.red
  end

  def save_zh!(lines : Array(String)) : Nil
    FileUtils.mkdir_p(@text_dir)

    ccount = lines.map(&.size).sum
    pcount = (ccount / PART_LIMIT).round.to_i
    wlimit = ccount // (pcount < 2 ? 1 : pcount)

    split_parts(lines, wlimit).each_with_index do |part, idx|
      @parts[idx] = part

      out_file = "#{@text_dir}/#{@schid}-#{idx}.txt"
      File.open(out_file, "w") { |io| part.join(io, "\n") }
      `zip -jqm #{@zip_file} #{out_file}`
    end

    puts "- <zh_text> [#{@sname}/#{@snvid}/#{@schid}] saved.".colorize.yellow
  end

  private def split_parts(lines : Array(String), limit = PART_LIMIT)
    parts = [[] of String]

    count = 0
    lines.each do |line|
      count += line.size

      if count > limit
        parts << [] of String
        count = 0
      end

      parts.last << line
    end

    parts
  end
end
