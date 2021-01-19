require "file_utils"
require "option_parser"

require "../../src/filedb/_inits/rm_info"
require "./_info_seed.cr"

class CV::Seeds::MapRemote
  def initialize(@s_name : String)
    @seeding = InfoSeed.new(@s_name)
  end

  def init!(upto = 1, mode = 1)
    puts "[ seed: #{@s_name}, upto: #{upto}, mode: #{mode} ]".colorize.cyan.bold
    mode = 0 if @s_name == "jx_la"

    1.upto(upto) do |idx|
      s_nvid = idx.to_s

      unless atime = access_time(s_nvid)
        next if mode < 1
        atime = (Time.utc + 3.minutes).to_unix
      end

      expiry = Time.utc
      if mode < 2 || @seeding._index.has_key?(s_nvid)
        next if @seeding._atime.ival_64(s_nvid) >= atime
        expiry -= 1.years
      elsif mode < 2
        expiry -= 1.years
      end

      @seeding._atime.add(s_nvid, atime)

      parser = RmInfo.init(@s_name, s_nvid, expiry: expiry)
      btitle, author = parser.btitle, parser.author
      next if btitle.empty? || author.empty?

      if @seeding._index.add(s_nvid, [btitle, author])
        @seeding.set_intro(s_nvid, parser.bintro)
        @seeding.genres.add(s_nvid, clean_genres(parser.genres))
        @seeding.bcover.add(s_nvid, parser.bcover)
      end

      @seeding.status.add(s_nvid, parser.status_int)
      @seeding._utime.add(s_nvid, parser.updated_at)

      if idx % 100 == 0
        puts "- [#{@s_name}]: <#{idx}/#{upto}>"
        @seeding.save!(mode: :upds)
      end
    rescue err
      puts err.colorize.red
    end

    @seeding.save!(mode: :full)
  end

  private def clean_genres(input : Array(String))
    input.map do |genre|
      genre == "轻小说" ? genre : genre.sub(/小说$/, "")
    end
  end

  private def access_time(s_nvid : String) : Int64?
    file = RmInfo.path_for(@s_name, s_nvid)
    File.info?(file).try(&.modification_time.to_unix)
  end

  def seed!
    authors = Set(String).new(NvValues.author.vals.map(&.first))
    checked = Set(String).new

    input = @seeding._index.data.to_a
    input.sort_by!(&.[0].to_i.-)

    input.each_with_index(1) do |(s_nvid, vals), idx|
      btitle, author = vals
      btitle, author = NvHelper.fix_nvname(btitle, author)

      nvname = "#{btitle}\t#{author}"
      next if checked.includes?(nvname)
      checked.add(nvname)

      if authors.includes?(author) || should_pick?(s_nvid)
        b_hash, _ = @seeding.upsert!(s_nvid)

        if NvValues.voters.ival(b_hash) == 0
          NvValues.set_score(b_hash, Random.rand(1..5), Random.rand(30..50))
        end
      end

      if idx % 100 == 0
        puts "- [#{@s_name}] <#{idx}/#{input.size}>".colorize.blue
        Nvinfo.save!(mode: :upds)
        @seeding.source.save!(mode: :upds)
      end
    end

    Nvinfo.save!(mode: :full)
    @seeding.source.save!(mode: :full)
  end

  private def should_pick?(s_nvid : String)
    return true if @s_name == "hetushu" || @s_name == "rengshu"
    false
  end

  def self.run!(argv = ARGV)
    site = ""
    upto = 1
    mode = 1

    OptionParser.parse(argv) do |parser|
      parser.banner = "Usage: map_remote [arguments]"
      parser.on("-s SITE", "--site=SITE", "Site name") { |x| site = x }
      parser.on("-u UPTO", "--upto=UPTO", "Latest id") { |x| upto = x.to_i }
      parser.on("-m MODE", "--mode=MODE", "Seed mode") { |x| mode = x.to_i }

      parser.invalid_option do |flag|
        STDERR.puts "ERROR: `#{flag}` is not a valid option."
        STDERR.puts parser
        exit(1)
      end
    end

    worker = new(site)
    worker.init!(upto, mode: mode)
    worker.seed!
  end
end

CV::Seeds::MapRemote.run!(ARGV)
