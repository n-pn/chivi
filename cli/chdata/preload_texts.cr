require "json"
require "colorize"
require "file_utils"

require "../../src/shared/zip_store"
require "../../src/kernel/import/book_meta"
require "../../src/kernel/mapper/value_map"

require "../../src/_oldcv/kernel/seeds/seed_text"

LIST_DIR = "_db/_extra/chlist"
TEXT_DIR = "_db/zhtext"

class PreloadBook
  MIN_SIZE = 20

  getter indexed_map : Chivi::ValueMap
  getter existed_zip : Chivi::ZipStore
  getter missing : Array(String)

  def initialize(@seed : String, @sbid : String)
    @out_dir = "#{TEXT_DIR}/#{@seed}/#{@sbid}"
    FileUtils.mkdir_p(@out_dir)

    @indexed_map = Chivi::ValueMap.new("#{LIST_DIR}/#{@seed}/#{@sbid}/_indexed.tsv")
    @existed_zip = Chivi::ZipStore.new("#{TEXT_DIR}/#{@seed}/#{@sbid}.zip")

    indexed_sbids = @indexed_map.values.values
    existed_sbids = @existed_zip.entries(MIN_SIZE).map(&.sub(".txt", ""))

    @missing = indexed_sbids - existed_sbids
  end

  def crawl!(threads = 4)
    threads = @missing.size if threads > @missing.size
    channel = Channel(Nil).new(threads + 1)

    @missing.each_with_index do |scid, idx|
      channel.receive unless idx < threads

      spawn do
        fetch_text(scid, "#{idx + 1}/#{@missing.size}")

        # throttling
        case @seed
        when "shubaow"
          sleep Random.rand(2000..3000).milliseconds
        when "zhwenpg"
          sleep Random.rand(1000..2000).milliseconds
        when "biquge5200"
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
    crawler = Oldcv::SeedText.new(@seed, @sbid, scid, freeze: true)
    out_file = "#{@out_dir}/#{scid}.txt"

    # if File.exists?(out_file) && File.size(out_file) < MIN_SIZE
    #   puts "- delete empty file [#{out_file}]".colorize.light_red
    #   File.delete(out_file)
    # end

    case crawler.title
    when .empty?, "Server Error", "524 Origin Time-out", "503 Service Temporarily Unavailable"
      puts "- delete empty html [#{crawler.file}]\n".colorize.light_red
      File.delete(crawler.file)
    else
      puts "- <#{label}> [#{crawler.title}] saved!\n".colorize.yellow
      File.write(out_file, crawler)
    end
  rescue err
    puts "- <#{label}> [#{@seed}/#{@sbid}/#{scid}]: #{err.message}".colorize.red
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
    map = Chivi::ValueMap.new("_db/prime/serial/seeds/#{@seed}/_index.tsv")

    res = [] of String

    Chivi::BookMeta.each_hash(order: "weight", seed: @seed) do |bhash|
      next unless value = map.get_value(bhash)
      next if main_seed && !is_main_seed(bhash)

      puts "- #{bhash}: #{Chivi::BookMeta.get_title_vi(bhash)}".colorize.cyan
      res << value
    end

    res
  end

  private def is_main_seed(bhash : String)
    return false unless seeds = Chivi::BookMeta.seeds_fs.get_value(bhash)

    case @seed
    when "zhwenpg", "nofff"
      # not considered main source if there are more than two sources
      return false if seeds.size > 2
    else
      # nofff is a shitty source
      seeds.shift if seeds.first == "nofff"
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
    when "hetushu", "rengshu"
      :best
    when "zhwenpg", "shubaow"
      :main
    else
      :main
    end
  end

  def self.ideal_thread_limit_for(seed : String)
    case seed
    when "zhwenpg", "shubaow", "qu_la", "biquge5200"
      1
    when "paoshu8", "69shu"
      2
    else
      4
    end
  end
end

PreloadSeed.crawl!(ARGV)
