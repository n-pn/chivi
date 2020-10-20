require "file_utils"
require "option_parser"

require "../../src/kernel/parser/seed_info"
require "../../src/kernel/lookup"

SEEDS = {
  "hetushu", "jx_la", "rengshu",
  "xbiquge", "nofff", "duokan8",
  "paoshu8", "69shu", "qu_la",
  "5200", "biquge5200",
  "kenwen", "mxguan",
}

class MapRemote
  DIR = File.join("var", "appcv", ".mapped")

  getter seed : String
  getter upto = 1

  def initialize(@seed, @upto, @mode : Int32 = 0)
    root = File.join(DIR, @seed)
    FileUtils.mkdir_p(root)

    @unames = LabelMap.load(File.join(root, "unames.txt"))

    @intros = LabelMap.load(File.join(root, "intros.txt"))
    @covers = LabelMap.load(File.join(root, "covers.txt"))

    @genres = LabelMap.load(File.join(root, "genres.txt"))
    @labels = LabelMap.load(File.join(root, "labels.txt"))

    @states = LabelMap.load(File.join(root, "states.txt"))
    @mtimes = LabelMap.load(File.join(root, "mtimes.txt"))

    @ctimes = LabelMap.load(File.join(root, "ctimes.txt"))
  end

  def run!
    queue = [] of Tuple(String, Time)

    1.upto(upto) do |sbid|
      sbid = sbid.to_s
      next unless expiry = expiry_for(sbid)
      queue << {sbid, expiry}
    end

    puts "\n[-- seed: #{@seed}, \
                upto: #{upto}, \
                size: #{queue.size}, \
                mode: #{@mode} --] ".colorize.cyan.bold

    worker = queue.size
    worker = 8 if worker > 8

    channel = Channel(SeedInfo).new(worker)

    queue.shuffle.each_with_index do |(sbid, expiry), idx|
      map_entry(channel.receive) if idx > worker

      spawn do
        parser = SeedInfo.new(@seed, sbid, expiry, freeze: true)

        begin
          puts "- <#{idx + 1}/#{queue.size}> #{parser.title}--#{parser.author}"
        rescue err
          puts err
        ensure
          # TODO: extract valuable data
          channel.send(parser)
        end
      end
    end

    worker.times { map_entry(channel.receive) }
    LabelMap.flush!
  end

  OLD = Time.utc - 12.months
  NEW = Time.utc - 3.hours

  def expiry_for(sbid : String) : Time?
    # for unmapped book entry
    return OLD unless uname = @unames.fetch(sbid)
    return OLD unless state = @states.fetch(sbid)
    return NEW unless mtime = @mtimes.fetch(sbid)
    return NEW unless ctime = @ctimes.fetch(sbid)

    # fast mapping mode, skipping mapped entries
    return if @mode == 0

    # skipp mapping recently cached entries
    # TODO: check with cached html_file mtime
    return if (Time.unix(ctime.to_i64) + 30.minutes) > Time.utc

    # redownload error pages
    if uname == "--"
      return @mode > 1 ? NEW : OLD
    end

    # don't download completed series
    mtime = Time.unix_ms(mtime.to_i64)
    return mtime if state == "1"

    # since these sites don't have update times
    return Time.utc - 1.days if @seed == "hetushu" || @seed == "zhwenpg"

    # recheck after 3 days
    mtime += 3.days
    mtime < NEW ? mtime : NEW
  end

  def map_entry(info : SeedInfo) : Void
    @unames.upsert!(info.sbid, "#{info.title}--#{info.author}")

    @intros.upsert!(info.sbid, info.intro.gsub('\n', LabelMap::SEP_1))
    @covers.upsert!(info.sbid, info.cover)

    @genres.upsert!(info.sbid, info.genre)
    @labels.upsert!(info.sbid, info.tags.join(LabelMap::SEP_1))

    @states.upsert!(info.sbid, info.status.to_s)
    @mtimes.upsert!(info.sbid, info.mftime.to_s)

    @ctimes.upsert!(info.sbid, Time.utc.to_unix.to_s)
  rescue err
    puts "ERROR: <#{info.sbid}> : #{err}".colorize.red
    info.delete_cache! if @mode > 0
    @unames.upsert!(info.sbid, "--")
  end

  def self.run!(argv = ARGV)
    seed = "hetushu"
    upto = 1
    mode = 0

    OptionParser.parse(argv) do |parser|
      parser.banner = "Usage: map_remote [arguments]"
      parser.on("-s SEED", "--seed=SEED", "Seed name") { |x| seed = x }
      parser.on("-u UPTO", "--upto=UPTO", "Last sbid") { |x| upto = x.to_i }
      parser.on("-m MODE", "--mode=MODE", "Parse mode") { |x| mode = x.to_i }

      parser.invalid_option do |flag|
        STDERR.puts "ERROR: `#{flag}` is not a valid option."
        STDERR.puts parser
        exit(1)
      end

      unless SEEDS.includes?(seed)
        STDERR.puts "ERROR: invalid seed `#{seed}`."
        exit(1)
      end
    end

    new(seed, upto, mode).run!
  end
end

MapRemote.run!
