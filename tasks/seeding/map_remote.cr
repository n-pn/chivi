require "file_utils"
require "option_parser"

require "../../src/filedb/nvinit/rm_info"
require "./_info_seed.cr"

class CV::Seeds::MapRemote
  def initialize(@seed : String)
    @seeding = InfoSeed.new(@seed)
  end

  def init!(upto = 1, skip_missing = false)
    skip_missing = true if @seed == "jx_la"

    1.upto(upto) do |idx|
      sbid = idx.to_s

      unless access_tz = access_time(sbid)
        next if skip_missing
        access_tz = (Time.utc + 3.minutes).to_unix
      end

      next if @seeding.access_tz.ival_64(sbid) >= access_tz
      @seeding.access_tz.add(sbid, access_tz)

      parser = RmInfo.init(@seed, sbid, expiry: Time.utc - 1.years)
      btitle, author = parser.btitle, parser.author
      next if btitle.empty? || author.empty?

      if @seeding._index.add(sbid, [btitle, author])
        @seeding.set_intro(sbid, parser.bintro)
        @seeding.bgenre.add(sbid, parser.bgenre)
        @seeding.bcover.add(sbid, parser.bcover)
      end

      @seeding.status.add(sbid, parser.status_int)
      @seeding.update_tz.add(sbid, parser.updated_at)

      if idx % 100 == 99
        puts "- [#{@seed}]: <#{idx + 1}/#{upto}>"
        @seeding.save!(mode: :upds)
      end
    rescue err
      puts err.colorize.red
    end

    @seeding.save!(mode: :full)
  end

  private def access_time(sbid : String) : Int64?
    file = RmInfo.path_for(@seed, sbid)
    File.info?(file).try(&.modification_time.to_unix)
  end

  def seed!
    authors = Set(String).new(Nvinfo.author.vals.map(&.first))
    checked = Set(String).new

    input = @seeding._index.data.to_a
    input.sort_by!(&.[0].to_i.-)

    input.each_with_index do |(sbid, vals), idx|
      btitle, author = vals
      btitle, author = Nvinfo::Utils.fix_nvname(btitle, author)

      nvname = "#{btitle}\t#{author}"
      next if checked.includes?(nvname)
      checked.add(nvname)

      if authors.includes?(author) || should_pick?(sbid)
        @seeding.upsert!(sbid)
      end

      if idx % 100 == 99
        puts "- [#{@seed}] <#{idx + 1}/#{input.size}>".colorize.blue
        Nvinfo.save!(mode: :upds)
      end
    end

    Nvinfo.save!(mode: :full)
  end

  private def should_pick?(sbid : String)
    return true if @seed == "hetushu" || @seed == "rengshu"
    false
  end

  def self.run!(argv = ARGV)
    seed = ""
    upto = 1
    skip_missing = false

    OptionParser.parse(argv) do |parser|
      parser.banner = "Usage: map_remote [arguments]"
      parser.on("-s SEED", "--seed=SEED", "Seed name") { |x| seed = x }
      parser.on("-u UPTO", "--upto=UPTO", "Latest id") { |x| upto = x.to_i }
      parser.on("-m", "--skip-missing", "Skip missing") { skip_missing = true }

      parser.invalid_option do |flag|
        STDERR.puts "ERROR: `#{flag}` is not a valid option."
        STDERR.puts parser
        exit(1)
      end
    end

    worker = new(seed)
    worker.init!(upto, skip_missing)
    worker.seed!
  end
end

CV::Seeds::MapRemote.run!(ARGV)
