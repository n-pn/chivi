require "json"
require "colorize"
require "file_utils"

require "../../src/_utils/zip_store"
require "../../src/filedb/value_map"
require "../../src/kernel/book_meta"
require "../../src/kernel/source/seed_text"

LIST_DIR = "_db/prime/chdata/infos"
TEXT_DIR = "_db/prime/chdata/texts"

class PreloadBook
  getter indexed : Array(String)
  getter existed : Array(String)
  getter missing : Array(String)

  def initialize(@seed : String, @sbid : String)
    @out_dir = "#{TEXT_DIR}/#{@seed}/#{@sbid}"
    FileUtils.mkdir_p(@out_dir)

    @indexed = ValueMap.new("#{LIST_DIR}/#{@seed}/#{@sbid}/_indexed.tsv").values.values
    @existed = ZipStore.new("#{TEXT_DIR}/#{@seed}/#{@sbid}.zip").entries.map(&.sub(".txt", ""))

    @missing = indexed - existed
  end

  def crawl!(threads = 4)
    threads = @missing.size if threads > @missing.size
    channel = Channel(Nil).new(threads)

    @missing.each_with_index do |scid, idx|
      channel.receive unless idx < threads

      spawn do
        fetch_text(scid, "#{idx + 1}/#{@missing.size}")
      ensure
        channel.send(nil)
      end
    end

    threads.times { channel.receive }
  end

  def fetch_text(scid : String, label : String) : Nil
    crawler = SeedText.new(@seed, @sbid, scid, freeze: true)
    File.write("#{@out_dir}/#{scid}.txt", crawler)
    puts "-- <#{label}> [#{crawler.title}] saved! --\n".colorize.yellow
  rescue err
    puts "-- <#{label}> [#{@seed}/#{@sbid}/#{scid}] #{err.message}}".colorize.red
  end

  def self.crawl!(seed : String, sbid : String, threads = 4)
    new(seed, sbid).crawl!(threads)
  end
end

class PreloadSeed
  getter sbids

  def initialize(@seed : String, mode = :all)
    @sbids =
      case mode
      when :main then get_sbids_by_weight(main_seed: true)
      when :best then get_sbids_by_weight(main_seed: false)
      else            Dir.children("#{LIST_DIR}/#{seed}")
      end
  end

  private def get_sbids_by_weight(main_seed = false)
    map = ValueMap.new("_db/prime/serial/seeds/#{@seed}/_index.tsv")

    res = [] of String

    BookMeta.each_hash(order: "weight", seed: @seed) do |bhash|
      next unless value = map.get_value(bhash)
      next if main_seed && !is_main_seed(bhash)

      puts "- #{bhash}: #{BookMeta.get_title_vi(bhash)}".colorize.cyan
      res << value
    end

    res
  end

  private def is_main_seed(bhash : String)
    return false unless seeds = BookMeta.seeds_fs.get_value(bhash)

    if @seed == "shubaow"
      # dirty hack for shubaow
      seeds = seeds.reject { |x| x == "nofff" || x == "jx_la" }
    end

    @seed == seeds.first
  end

  def crawl!(text_threads = 4)
    @sbids.each_with_index do |sbid, idx|
      puts "- #{idx + 1}/#{@sbids.size} [#{@seed}/#{sbid}]".colorize.light_cyan
      PreloadBook.crawl!(@seed, sbid, text_threads)
    end
  end

  def self.crawl!(argv = ARGV, mode = :best)
    seeds = ARGV.empty? ? ["zhwenpg", "shubaow"] : ARGV
    seeds.each do |seed|
      crawler = PreloadSeed.new(seed, ideal_crawl_mode_for(seed))
      puts "[#{seed}: #{crawler.sbids.size} entries]".colorize.green.bold

      crawler.crawl!(text_threads: ideal_thread_limit_for(seed))
    end
  end

  def self.ideal_crawl_mode_for(seed : String)
    case seed
    when "zhwenpg", "shubaow"
      :main
    else
      :best
    end
  end

  def self.ideal_thread_limit_for(seed : String)
    case seed
    when "zhwenpg", "shubaow", "qu_la"
      1
    else
      4
    end
  end
end

PreloadSeed.crawl!(ARGV)
