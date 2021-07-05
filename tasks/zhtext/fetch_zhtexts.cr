# require "json"
require "colorize"
require "file_utils"
require "option_parser"
require "compress/zip"

require "../../src/appcv/filedb/ch_text"
require "../../src/tsvfs/value_map"

class CV::FetchBook
  def initialize(@sname : String, @snvid : String)
    @dir = "_db/chseed/#{@sname}/#{@snvid}"
  end

  private def scan_for_missing(min_size : Int32)
    output = {} of String => Int32

    index_map = ValueMap.new("#{@dir}/_id.tsv", mode: 1)
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
  getter snvids = [] of String

  def initialize(@sname : String)
    lines = File.read_lines("priv/zhseed.tsv")

    lines.each do |line|
      vals = line.split('\t', 3)
      next if vals.size < 3

      next unless @sname == vals[0]
      @snvids << vals[1]
    end
  end

  def crawl!(wrks = 4)
    puts "[#{@sname}: #{@snvids.size} entries]".colorize.green.bold

    @snvids.each_with_index(1) do |snvid, idx|
      worker = FetchBook.new(@sname, snvid)
      worker.crawl!(wrks: wrks, label: "#{idx}/#{@snvids.size}")
    end
  end

  def self.run!(argv = ARGV)
    sname, snvid = "hetushu", "1"
    mode, wrks = :multi, 0

    OptionParser.parse(ARGV) do |opt|
      opt.banner = "Usage: fetch_zhtexts [arguments]"
      opt.on("-t WORKERS", "Parallel workers") { |x| wrks = x.to_i }
      opt.on("-s SNAME", "Seed name") { |x| sname = x }

      opt.on("single", "Fetch a single book") do
        mode = :single
        opt.banner = "Usage: fetch_zhtexts single [arguments]"
        opt.on("-n SNVID", "Seed book id") { |x| snvid = x }
      end

      opt.on("multi", "Fetch multi books") do
        mode = :multi
        opt.banner = "Usage: fetch_zhtexts multi [arguments]"
      end

      opt.invalid_option do |flag|
        STDERR.puts "ERROR: `#{flag}` is not a valid option."
        STDERR.puts opt
        exit(1)
      end
    end

    wrks = RmUtil.ideal_workers_count_for(sname) if wrks < 1

    case mode
    when :single
      puts "[#{sname} - #{snvid} - #{wrks}]".colorize.cyan.bold
      FetchBook.new(sname, snvid).crawl!(wrks: wrks)
    when :multi
      puts "[#{sname} - #{wrks}]".colorize.cyan.bold
      FetchSeed.new(sname).crawl!(wrks: wrks)
    end
  end
end

CV::FetchSeed.run!
