require "option_parser"

require "../../src/seeds/rm_info"
require "../../src/tabkv/value_map"
require "./shared/seed_data"
require "./shared/seed_util"

class CV::InitRemote
  def initialize(@zseed : String)
    @seed = SeedData.new(@zseed)
  end

  def build!(upper : Int32)
    upper = SeedUtil.last_snvid(@zseed).to_i if upper < 1
    missing, updates = [] of String, [] of String

    read_stats(upper) do |snvid, state|
      missing << snvid if state > 1
      updates << snvid if state ^ 1 != 0
    end

    {missing, updates}
  end

  def read_stats(upper : Int32)
    limit = 20
    channel = Channel(Tuple(String, Int32)).new(limit + 1)

    1.upto(upper) do |index|
      spawn do
        snvid = index.to_s
        fpath = "_db/.cache/#{@zseed}/infos/#{snvid}.html.gz"

        mtime = SeedUtil.get_mtime(fpath)   # html cached if mtime > 0
        atime = @seed._index.ival_64(snvid) # book parsed if atime > 0

        if mtime > 0
          channel.send({snvid, atime >= mtime ? 1 : 0})
        else
          channel.send({snvid, atime > 0 ? 3 : 2})
        end
      end

      yield channel.receive if index > limit
    end

    limit.times { yield channel.receive }
  end

  def crawl!(queue : Array(String), threads = 0)
    threads = SeedUtil.max_threads(@zseed) if threads < 1
    threads = queue.size if threads > queue.size

    puts "[#{@zseed}], missing: #{queue.size}, workers: #{threads}\n".colorize.cyan.bold

    RmInfo.mkdir!(@zseed) # ensure the seed cache folde
    channel = Channel(Nil).new(threads)
    encoding = HttpUtils.encoding_for(@zseed)

    queue.each_with_index(1) do |snvid, index|
      spawn do
        entry = RmInfo.new(@zseed, snvid)
        label = "#{index}/#{queue.size}"

        html = HttpUtils.get_html(entry.link, label: label, encoding: encoding)
        HttpUtils.save_html(entry.file, html)

        # throttling if success
        sleep SeedUtil.sleep_time(@zseed)
      rescue err
        puts err
      ensure
        channel.send(nil)
      end

      channel.receive if index > threads
    end

    threads.times { channel.receive }
  end

  def parse!(queue : Array(String))
    puts "[#{@zseed}], parsing: #{queue.size}\n".colorize.cyan.bold

    queue.each_with_index(1) do |snvid, idx|
      entry = RmInfo.new(@zseed, snvid)
      atime = SeedUtil.get_mtime(entry.file)

      @seed._index.set!(snvid, [atime.to_s, entry.btitle, entry.author])
      @seed.set_intro(snvid, entry.bintro)

      @seed.genres.set!(snvid, entry.genres)
      @seed.bcover.set!(snvid, entry.bcover)

      @seed.status.set!(snvid, entry.status)
      @seed.update.set!(snvid, entry.update)

      if idx % 100 == 0
        puts "- [#{@zseed}]: <#{idx}/#{queue.size}>"
        @seed.save!(clean: false)
      end
    end

    @seed.save!(clean: false)
  end
end

def run!(argv = ARGV)
  zseed, upper = "hetushu", 0
  cr_mode, threads = 0, 0

  OptionParser.parse(argv) do |parser|
    parser.banner = "Usage: map_remote [arguments]"
    parser.on("-s SNAME", "Remote name") { |x| zseed = x }
    parser.on("-u UPPER", "Upper snvid") { |x| upper = x.to_i }
    parser.on("-m CR_MODE", "Crawling mode") { |x| cr_mode = x.to_i }
    parser.on("-t THREADS", "Concurrent threads") { |x| threads = x.to_i }

    parser.invalid_option do |flag|
      STDERR.puts "ERROR: `#{flag}` is not a valid option."
      STDERR.puts parser
      exit(1)
    end
  end

  worker = CV::InitRemote.new(zseed)

  # cr_mode:
  # - 0: crawl missings, parse missing and updates/unparsed
  # - 1: crawl and parse missing
  # - 2: parse updates/unparsed only

  missing, updates = worker.build!(upper)

  if cr_mode < 2
    worker.crawl!(missing, threads)
    worker.parse!(missing)
  end

  updates -= missing if zseed == "jx_la"
  worker.parse!(updates) if cr_mode != 1
end

run!(ARGV)
