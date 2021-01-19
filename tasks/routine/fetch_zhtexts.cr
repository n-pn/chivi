require "json"
require "colorize"
require "file_utils"
require "option_parser"

require "../../src/filedb/nvinfo"
require "../../src/filedb/_inits/rm_text"

LIST_DIR = "_db/chdata/chinfos"
TEXT_DIR = "_db/chdata/zhtexts"

class CV::PreloadBook
  MIN_SIZE = 10

  getter indexed_map : CV::ValueMap
  getter existed_zip : CV::ZipStore
  getter missing : Array(String)

  def initialize(@s_name : String, @s_nvid : String)
    @out_dir = "#{TEXT_DIR}/#{@s_name}/#{@s_nvid}"
    ::FileUtils.mkdir_p(@out_dir)

    @indexed_map = CV::ValueMap.new("#{LIST_DIR}/#{@s_name}/origs/#{@s_nvid}.tsv")
    @existed_zip = CV::ZipStore.new("#{TEXT_DIR}/#{@s_name}/#{@s_nvid}.zip")

    indexed_scids = @indexed_map.data.keys
    existed_scids = @existed_zip.entries(MIN_SIZE).map(&.sub(".txt", ""))

    @missing = indexed_scids - existed_scids
  end

  def crawl!(threads = 4)
    threads = @missing.size if threads > @missing.size
    channel = Channel(Nil).new(threads)

    @missing.each_with_index do |scid, idx|
      channel.receive if idx > threads

      spawn do
        fetch_text(scid, "#{idx + 1}/#{@missing.size}")

        # throttling
        case @s_name
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

  def fetch_text(scid : String, label : String) : Nil
    source = CV::RmText.init(@s_name, @s_nvid, scid)
    out_file = "#{@out_dir}/#{scid}.txt"

    puts "- <#{label}> [#{source.title}] saved!\n".colorize.yellow

    File.open(out_file, "w") do |io|
      io.puts(source.title)
      source.paras.join(io, "\n")
    end
  rescue err
    puts "- <#{label}> [#{@s_name}/#{@s_nvid}/#{scid}]: #{err.message}".colorize.red
  end

  def self.crawl!(seed : String, sbid : String, threads = 4)
    new(seed, sbid).crawl!(threads)
  end
end

class CV::PreloadSeed
  @sbids : Array(String)

  def initialize(@s_name : String, fetch_all : Bool = false)
    input = NvValues.chseed.data.compact_map do |b_hash, chseed|
      next unless sbid = extract_seed(chseed, fetch_all)
      weight = NvValues.weight.ival(b_hash)
      {sbid, weight} if weight > 10
    end

    @sbids = input.sort_by { |_, weight| -weight }.map(&.[0])
  end

  private def extract_seed(seeds : Array(String), fetch_all : Bool = false)
    case @s_name
    when "zhwenpg", "nofff"
      # not considered main source if there are more than two sources
      return if seeds.size > 2
    else
      # nofff is a shitty source
      seeds.shift if seeds.first.starts_with?("nofff")
    end

    seeds.each_with_index do |input, index|
      name, sbid = input.split("/")
      next unless name == @s_name
      return sbid if fetch_all || index == 0
    end
  end

  def crawl!(threads = 4)
    puts "[#{@s_name}: #{@sbids.size} entries]".colorize.green.bold

    @sbids.each_with_index do |sbid, idx|
      puts "- #{idx + 1}/#{@sbids.size} [#{@s_name}/#{sbid}]".colorize.light_cyan
      PreloadBook.crawl!(@s_name, sbid, threads)
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
