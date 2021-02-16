require "json"
require "colorize"
require "file_utils"
require "option_parser"

require "../../src/filedb/nvinfo"
require "../../src/source/rm_chtext"

LIST_DIR = "_db/chdata/chinfos"
TEXT_DIR = "_db/chdata/zhtexts"

class CV::PreloadBook
  MIN_SIZE = 10

  getter indexed_map : CV::ValueMap
  getter existed_zip : CV::ZipStore
  getter missing : Array(String)

  def initialize(@sname : String, @snvid : String)
    @out_dir = "#{TEXT_DIR}/#{@sname}/#{@snvid}"
    ::FileUtils.mkdir_p(@out_dir)

    @indexed_map = CV::ValueMap.new("#{LIST_DIR}/#{@sname}/origs/#{@snvid}.tsv")
    @existed_zip = CV::ZipStore.new("#{TEXT_DIR}/#{@sname}/#{@snvid}.zip")

    indexed_chids = @indexed_map.data.keys
    existed_chids = @existed_zip.entries(MIN_SIZE).map(&.sub(".txt", ""))

    @missing = indexed_chids - existed_chids
  end

  def crawl!(threads = 4)
    threads = @missing.size if threads > @missing.size
    channel = Channel(Nil).new(threads)

    @missing.each_with_index(1) do |schid, idx|
      channel.receive if idx > threads

      spawn do
        fetch_text(schid, "#{idx}/#{@missing.size}")

        # throttling
        case @sname
        when "shubaow"
          sleep Random.rand(2000..3000).milliseconds
        when "zhwenpg"
          sleep Random.rand(1000..2000).milliseconds
        when "bqg_5200"
          sleep Random.rand(500..1000).milliseconds
        end
      ensure
        channel.send(nil)
      end
    end

    threads.times { channel.receive }
    @existed_zip.compress!(mode: :archive) # save texts to zip files
  end

  def fetch_text(schid : String, label : String) : Nil
    source = CV::RmChtext.new(@sname, @snvid, schid)
    out_file = "#{@out_dir}/#{schid}.txt"

    puts "- <#{label}> [#{source.title}] saved!\n".colorize.yellow

    File.open(out_file, "w") do |io|
      io.puts(source.title)
      source.paras.join(io, "\n")
    end
  rescue err
    puts "- <#{label}> [#{@sname}/#{@snvid}/#{schid}]: #{err.message}".colorize.red
  end

  def self.crawl!(seed : String, snvid : String, threads = 4)
    new(seed, snvid).crawl!(threads)
  end
end

class CV::PreloadSeed
  @snvids : Array(String)

  def initialize(@sname : String, fetch_all : Bool = false)
    input = NvValues.source.data.compact_map do |bhash, chseed|
      next unless snvid = extract_seed(chseed, fetch_all)
      weight = NvValues.weight.ival(bhash)
      {snvid, weight} if weight > 10
    end

    @snvids = input.sort_by { |_, weight| -weight }.map(&.[0])
  end

  private def extract_seed(input : Array(String), fetch_all : Bool = false)
    case @sname
    when "zhwenpg", "nofff"
      # not considered main source if there are more than two sources
      return if input.size > 2
    else
      # nofff is a shitty source
      input.shift if input.first.starts_with?("nofff")
    end

    input.each_with_index do |entry, idx|
      sname, snvid = entry.split("/")
      next unless sname == @sname
      return snvid if fetch_all || idx == 0
    end
  end

  def crawl!(threads = 4)
    puts "[#{@sname}: #{@snvids.size} entries]".colorize.green.bold

    @snvids.each_with_index(1) do |snvid, idx|
      puts "- #{idx}/#{@snvids.size} [#{@sname}/#{snvid}]".colorize.light_cyan
      PreloadBook.crawl!(@sname, snvid, threads)
    end
  end

  def self.crawl!(argv = ARGV)
    seed = "zhwenpg"

    threads = nil
    fetch_all = nil

    OptionParser.parse(argv) do |parser|
      parser.banner = "Usage: fetch_zhtexts [arguments]"
      parser.on("-s SEED", "Seed name") { |x| seed = x }
      parser.on("-a", "Fetch all") { |x| fetch_all = !!x }
      parser.on("-t THREADS", "Parallel threads") { |x| threads = x.to_i? }

      parser.invalid_option do |flag|
        STDERR.puts "ERROR: `#{flag}` is not a valid option."
        STDERR.puts parser
        exit(1)
      end
    end

    fetch_all ||= seed == "hetushu"
    threads ||= default_threads_for(seed)
    PreloadSeed.new(seed, fetch_all.not_nil!).crawl!(threads: threads.not_nil!)
  end

  def self.default_threads_for(seed : String) : Int32
    case seed
    when "zhwenpg", "shubaow", "bqg_5200" then 1
    when "paoshu8", "69shu"               then 2
    else                                       4
    end
  end
end

CV::PreloadSeed.crawl!(ARGV)
