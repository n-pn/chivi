# require "json"
require "colorize"
require "file_utils"
require "option_parser"
require "compress/zip"

require "../../src/appcv/filedb/nv_info"
require "../../src/appcv/filedb/ch_text"
require "../../src/tabkv/value_map"

class CV::FetchBook
  getter schids = Hash(String, Int32).new

  def initialize(@sname : String, @snvid : String, label = "1/1")
    @dir = "_db/chseed/#{@sname}/#{@snvid}"

    find_missing_schids!

    puts "- <#{label}> [#{@sname}/#{@snvid}] #{@schids.size} entries".colorize.light_cyan
  end

  def find_missing_schids!
    index_map = ValueMap.new("#{@dir}/_id.tsv", mode: 1)

    index_map.data.each do |chidx, value|
      @schids[value.first] = chidx.to_i - 1
    end

    Dir.glob("#{@dir}/*.zip").each do |zip_file|
      Compress::Zip::File.open(zip_file) do |zip|
        zip.entries.each do |entry|
          schid = File.basename(entry.filename, ".txt")
          schids.delete(schid)
        end
      end
    end
  end

  def crawl!(threads = 4)
    return if @schids.empty?

    threads = @schids.size if threads > @schids.size

    channel = Channel(Nil).new(threads + 1)
    @schids.each_with_index(1) do |(schid, chidx), idx|
      channel.receive if idx > threads

      spawn do
        chtext = ChText.new("_", @sname, @snvid, chidx, schid)
        chtext.fetch_zh!(mkdir: false, label: "#{idx}/#{@schids.size}")
        # throttling
        case @sname
        when "shubaow"
          sleep Random.rand(1000..2000).milliseconds
        when "zhwenpg"
          sleep Random.rand(400..1000).milliseconds
        when "bqg_5200"
          sleep Random.rand(100..400).milliseconds
        end
      rescue err
        puts "- <#{idx}> [#{@sname}/#{@snvid}/#{schid}]: #{err}".colorize.red
      ensure
        channel.send(nil)
      end
    end

    threads.times { channel.receive }
  end
end

class CV::FetchSeed
  getter snvids = [] of String

  def initialize(@sname : String, fetch_all : Bool = false)
    input = [] of Tuple(String, Int32)

    NvChseed.seed_map(sname).data.each do |bhash, value|
      next unless fetch_all || should_crawl?(bhash)
      input << {value.first, -NvOrders.weight.ival(bhash)}
    end

    @snvids = input.sort_by(&.[1]).map(&.[0])
  end

  SORT_ORDER = {
    "hetushu", "rengshu", "bxwxorg", "biqubao",
    "xbiquge", "paoshu8", "5200", "bqg_5200",
    "shubaow", "duokan8", "zhwenpg", "nofff",
  }

  def should_crawl?(bhash : String)
    snames = NvChseed._index.get(bhash) || [] of String
    return false if snames.empty?

    case @sname
    when "zhwenpg", "shubaow", "paoshu8", "nofff", "bqg_5200", "5200"
      return false if snames.size > 3
    else
      snames = snames.sort_by { |sname| SORT_ORDER.index(sname) || 99 }
    end

    snames.first == @sname
  end

  def crawl!(threads = 4)
    puts "[#{@sname}: #{@snvids.size} entries]".colorize.green.bold

    @snvids.each_with_index(1) do |snvid, idx|
      puts "\n[#{idx}/#{@snvids.size}]".colorize.yellow
      FetchBook.new(@sname, snvid).crawl!(threads: threads)
    end
  end

  def self.crawl!(argv = ARGV)
    sname = "zhwenpg"

    fetch_all = sname == "hetushu"
  end
end

# CV::PreloadSeed.crawl!(ARGV)

mode = :multi

threads = 0
sname = "hetushu"

snvid = "1"
fetch_all = false

OptionParser.parse(ARGV) do |opt|
  opt.banner = "Usage: fetch_zhtexts [arguments]"
  opt.on("-t THREADS", "Parallel workers") { |x| threads = x.to_i }
  opt.on("-s SNAME", "Seed name") { |x| sname = x }

  opt.on("single", "Fetch a single book") do
    mode = :single
    opt.banner = "Usage: fetch_zhtexts single [arguments]"
    opt.on("-n SNVID", "Seed book id") { |x| snvid = x }
  end

  opt.on("multi", "Fetch multi books") do
    mode = :multi
    opt.banner = "Usage: fetch_zhtexts multi [arguments]"
    opt.on("-a", "Fetch all") { fetch_all = true }
  end

  opt.invalid_option do |flag|
    STDERR.puts "ERROR: `#{flag}` is not a valid option."
    STDERR.puts opt
    exit(1)
  end
end

threads = CV::RmUtil.ideal_workers_count_for(sname) if threads < 1

case mode
when :single
  puts "[#{sname} - #{snvid} - #{threads}]".colorize.cyan.bold
  CV::FetchBook.new(sname, snvid).crawl!(threads: threads)
when :multi
  fetch_all = true if sname == "hetushu"
  puts "[#{sname} - #{fetch_all} - #{threads}]".colorize.cyan.bold
  CV::FetchSeed.new(sname, fetch_all).crawl!(threads: threads)
end
