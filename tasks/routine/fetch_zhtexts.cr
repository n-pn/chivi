require "json"
require "colorize"
require "file_utils"

require "../../src/filedb/nvinfo"
require "../../src/filedb/zhtext"
require "../../src/filedb/nvinit/rm_text"

LIST_DIR = "_db/nvdata/chinfos"
TEXT_DIR = "_db/nvdata/zhtexts"

class CV::PreloadBook
  MIN_SIZE = 20

  getter indexed_map : CV::ValueMap
  getter existed_zip : CV::ZipStore
  getter missing : Array(String)

  def initialize(@seed : String, @sbid : String)
    @out_dir = "#{TEXT_DIR}/#{@seed}/#{@sbid}"
    ::FileUtils.mkdir_p(@out_dir)

    @indexed_map = CV::ValueMap.new("#{LIST_DIR}/#{@seed}/#{@sbid}/index.tsv")
    @existed_zip = CV::ZipStore.new("#{TEXT_DIR}/#{@seed}/#{@sbid}.zip")

    indexed_scids = @indexed_map.data.keys
    existed_scids = @existed_zip.entries(MIN_SIZE).map(&.sub(".txt", ""))

    @missing = indexed_scids - existed_scids
  end

  def crawl!(threads = 4)
    threads = @missing.size if threads > @missing.size
    channel = Channel(Nil).new(threads + 1)

    @missing.each_with_index do |scid, idx|
      channel.receive if idx > threads

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
    source = CV::RmText.init(@seed, @sbid, scid)
    out_file = "#{@out_dir}/#{scid}.txt"

    puts "- <#{label}> [#{source.title}] saved!\n".colorize.yellow

    File.open(out_file, "w") do |io|
      io.puts(source.title)
      source.paras.join(io, "\n")
    end
  rescue err
    puts "- <#{label}> [#{@seed}/#{@sbid}/#{scid}]: #{err.message}".colorize.red
  end

  def self.crawl!(seed : String, sbid : String, threads = 4)
    new(seed, sbid).crawl!(threads)
  end
end

class CV::PreloadSeed
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
    input = Nvinfo.chseed.data.compact_map do |bhash, chseed|
      next unless sbid = extract_seed(chseed, main_seed)
      {bhash, sbid}
    end

    input.sort_by { |(bhash, _)| Nvinfo.weight.ival(bhash).- }.map(&.[1])
  end

  private def extract_seed(seeds : Array(String), main_only : Bool = false)
    case @seed
    when "zhwenpg", "nofff"
      # not considered main source if there are more than two sources
      return if seeds.size > 2
    else
      # nofff is a shitty source
      seeds.shift if seeds.first.starts_with?("nofff")
    end

    seeds.each_with_index do |input, index|
      name, sbid = input.split("/")
      next unless name == @seed
      return (main_only && index > 0) ? nil : sbid
    end

    nil
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

CV::PreloadSeed.crawl!(ARGV)
