# require "json"
require "colorize"
require "file_utils"
require "option_parser"
require "compress/zip"

require "../../src/appcv/filedb/ch_text"
require "../../src/cutil/value_map"

class CV::FetchBook
  def initialize(@sname : String, @snvid : String)
    @dir = "_db/chseed/#{@sname}/#{@snvid}"
  end

  private def scan_for_missing(min_size : Int32)
    output = {} of String => Int32

    index_map = TsvStore.new("#{@dir}/_id.tsv", mode: 1)
    index_map.data.keys.each_with_index do |snvid, index|
      output[snvid] = index
    end

    Dir.glob("#{@dir}/*.zip").each do |zip_file|
      Compress::Zip::File.open(zip_file) do |zip|
        zip.entries.each do |entry|
          next if entry.uncompressed_size < min_size
          schid = File.basename(entry.filename, ".txt")
          output.delete(schid)
        end
      end
    end

    output
  end

  def crawl!(wrks = 4, label = "1/1")
    queue = scan_for_missing(min_size = 1)
    return if queue.empty?

    wrks = queue.size if wrks > queue.size
    puts "- <#{label}> [#{@sname}/#{@snvid}] #{queue.size} entries".colorize.light_cyan

    ::FileUtils.mkdir_p(RmText.c_dir(@sname, @snvid))

    channel = Channel(Nil).new(wrks + 1)
    queue.each_with_index(1) do |(schid, chidx), idx|
      spawn do
        chtext = ChText.new("_", @sname, @snvid, chidx, schid)
        chtext.fetch_zh!(mkdir: false, label: "#{idx}/#{queue.size}")
      rescue err
        puts "- <#{idx}> [#{@sname}/#{@snvid}/#{schid}]: #{err}".colorize.red
      else
        # throttling
        case @sname
        when "shubaow"
          sleep Random.rand(1000..2000).milliseconds
        when "zhwenpg"
          sleep Random.rand(400..1000).milliseconds
        when "bqg_5200"
          sleep Random.rand(100..400).milliseconds
        end
      ensure
        channel.send(nil)
      end

      channel.receive if idx > wrks
    end

    wrks.times { channel.receive }
  end
end

class CV::FetchSeed
  def initialize(@sname : String, @favi = false)
  end

  def crawl!(wrks = 4)
    queue = [] of String

    File.read_lines("priv/zhseed.tsv").each do |line|
      parts = line.split('\t', 4)
      next if parts.size < 3

      sname, snvid, bhash = parts
      queue << snvid if should_crawl?(bhash, sname)
    end

    puts "[#{@sname}: #{queue.size} entries]".colorize.green.bold

    queue.each_with_index(1) do |snvid, idx|
      worker = FetchBook.new(@sname, snvid)
      worker.crawl!(wrks: wrks, label: "#{idx}/#{queue.size}")
    end
  end

  def should_crawl?(bhash : String, sname : String)
    return false if sname != @sname
    !@favi || library.includes?(bhash)
  end

  getter library : Set(String) do
    inp_dir = "_db/vi_users/marks"
    bhashes = Dir.children(inp_dir).map { |x| File.basename(x, ".tsv") }
    Set(String).new(bhashes)
  end

  def self.run!(argv = ARGV)
    sname, snvid = "hetushu", "1"
    mode, wrks, favi = :multi, 0, false

    OptionParser.parse(ARGV) do |opt|
      opt.banner = "Usage: fetch_zhtexts [arguments]"
      opt.on("-t WORKERS", "Parallel workers") { |x| wrks = x.to_i }

      opt.on("single", "Fetch a single book") do
        mode = :single
        opt.banner = "Usage: fetch_zhtexts single [arguments]"
        opt.on("-s SNAME", "Seed name") { |x| sname = x }
        opt.on("-n SNVID", "Seed book id") { |x| snvid = x }
      end

      opt.on("multi", "Fetch multi books") do
        mode = :multi
        opt.banner = "Usage: fetch_zhtexts multi [arguments]"
        opt.on("-s SNAMES", "Seed names") { |x| sname = x }
        opt.on("-f", "Only favorited books") { favi = true }
      end

      opt.invalid_option do |flag|
        STDERR.puts "ERROR: `#{flag}` is not a valid option."
        STDERR.puts opt
        exit(1)
      end
    end

    wrks = ideal_workers_count_for(sname) if wrks < 1

    case mode
    when :single
      puts "[#{sname} - #{snvid} - #{wrks}]".colorize.cyan.bold
      FetchBook.new(sname, snvid).crawl!(wrks: wrks)
    when :multi
      puts "[sname: #{sname}, workers: #{wrks}]".colorize.cyan.bold
      FetchSeed.new(sname, favi: favi).crawl!(wrks: wrks)
    end
  end

  def self.ideal_workers_count_for(sname : String) : Int32
    case sname
    when "zhwenpg", "shubaow"  then 1
    when "paoshu8", "bqg_5200" then 2
    when "duokan8", "69shu"    then 4
    else                            6
    end
  end
end

CV::FetchSeed.run!
