require "file_utils"
require "option_parser"

require "../../src/source/rm_info"
require "./_seeding.cr"

class CV::Seeds::MapRemote
  def initialize(@s_name : String)
    @seeding = InfoSeed.new(@s_name)
  end

  def init!(upto = 1, mode = 1)
    puts "[ seed: #{@s_name}, upto: #{upto}, mode: #{mode} ]".colorize.cyan.bold
    mode = 0 if @s_name == "jx_la"

    1.upto(upto) do |idx|
      snvid = idx.to_s

      unless atime = access_time(snvid)
        next if mode < 1
        atime = (Time.utc + 3.minutes).to_unix
      end

      expiry = Time.utc
      if mode < 2 || @seeding._index.has_key?(snvid)
        next if @seeding._atime.ival_64(snvid) >= atime
        expiry -= 1.years
      elsif mode < 2
        expiry -= 1.years
      end

      @seeding._atime.add(snvid, atime)

      parser = RmInfo.init(@s_name, snvid, expiry: expiry)
      btitle, author = parser.btitle, parser.author
      next if btitle.empty? || author.empty?

      if @seeding._index.add(snvid, [btitle, author])
        @seeding.set_intro(snvid, parser.bintro)
        @seeding.genres.add(snvid, clean_genres(parser.genres))
        @seeding.bcover.add(snvid, parser.bcover)
      end

      @seeding.status.add(snvid, parser.status_int)
      @seeding._utime.add(snvid, parser.updated_at.to_unix)

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

  private def access_time(snvid : String) : Int64?
    file = RmInfo.path_for(@s_name, snvid)
    File.info?(file).try(&.modification_time.to_unix)
  end

  def seed!
    authors = Set(String).new(NvValues.author.vals.map(&.first))
    checked = Set(String).new

    input = @seeding._index.data.to_a
    input.sort_by!(&.[0].to_i.-)

    input.each_with_index(1) do |(snvid, vals), idx|
      btitle, author = vals
      btitle, author = NvHelper.fix_nvname(btitle, author)

      nvname = "#{btitle}\t#{author}"
      next if checked.includes?(nvname)
      checked.add(nvname)

      if authors.includes?(author) || should_pick?(snvid)
        bhash, _ = @seeding.upsert!(snvid)

        if NvValues.voters.ival(bhash) == 0
          NvValues.set_score(bhash, Random.rand(1..5), Random.rand(30..50))
        end
      end

      if idx % 100 == 0
        puts "- [#{@s_name}] <#{idx}/#{input.size}>".colorize.blue
        Nvinfo.save!(mode: :upds)
        @seeding.source.save!(mode: :upds)
      end
    rescue err
      puts err
      puts [snvid, vals]
      gets
    end

    Nvinfo.save!(mode: :full)
    @seeding.source.save!(mode: :full)
  end

  private def should_pick?(snvid : String)
    return true if @s_name == "hetushu" || @s_name == "rengshu"
    false
  end

  def self.run!(argv = ARGV)
    site = ""
    upto = 1
    mode = 1

    OptionParser.parse(argv) do |parser|
      parser.banner = "Usage: map_remote [arguments]"
      parser.on("-s SITE", "Site name") { |x| site = x }
      parser.on("-u UPTO", "Latest id") { |x| upto = x.to_i }
      parser.on("-m MODE", "Seed mode") { |x| mode = x.to_i }

      parser.invalid_option do |flag|
        STDERR.puts "ERROR: `#{flag}` is not a valid option."
        STDERR.puts parser
        exit(1)
      end
    end

    worker = new(site)
    worker.init!(upto, mode: mode)
    worker.seed! if mode >= 0
  end
end

CV::Seeds::MapRemote.run!(ARGV)
