require "file_utils"
require "option_parser"

require "../../src/source/rm_nvinfo"
require "./_seeding.cr"

class CV::Seeds::MapRemote
  def initialize(@sname : String)
    @seeding = InfoSeed.new(@sname)
  end

  def prep!(upto = 1)
    queue = [] of Tuple(String, String)

    1.upto(upto) do |idx|
      snvid = idx.to_s
      file = RmSpider.nvinfo_file(@sname, snvid)

      next if File.exists?(file)
      queue << {file, RmSpider.nvinfo_link(@sname, snvid)}
    end

    puts "[ seed: #{@sname}, upto: #{upto}, queue: #{queue.size} ]".colorize.cyan.bold

    threads = ideal_threads_for(@sname)
    threads = queue.size if threads > queue.size
    channel = Channel(Nil).new(threads)

    queue.each_with_index(1) do |(file, link), idx|
      channel.receive if idx > threads

      spawn do
        encoding = HttpUtils.encoding_for(@sname)
        html = HttpUtils.get_html(link, encoding, label: "#{idx}/#{queue.size}")

        File.write(file, html)

        # throttling
        case @sname
        when "shubaow"
          sleep Random.rand(1000..2000).milliseconds
        when "zhwenpg"
          sleep Random.rand(500..1000).milliseconds
        when "bqg_5200"
          sleep Random.rand(100..500).milliseconds
        end
      rescue err
        puts err
      ensure
        channel.send(nil)
      end
    end

    threads.times { channel.receive }
  end

  def ideal_threads_for(sname : String)
    case sname
    when "zhwenpg", "shubaow"           then 1
    when "paoshu8", "69shu", "bqg_5200" then 3
    when "hetushu", "duokan8"           then 6
    else                                     10
    end
  end

  def init!(upto = 1, mode = 1)
    puts "[ seed: #{@sname}, upto: #{upto}, mode: #{mode} ]".colorize.cyan.bold
    mode = 0 if @sname == "jx_la"

    1.upto(upto) do |idx|
      snvid = idx.to_s

      unless atime = access_time(snvid)
        next if mode < 1
        atime = (Time.utc + 3.minutes).to_unix
      end

      if mode < 2 || @seeding._index.has_key?(snvid)
        next if @seeding._atime.ival_64(snvid) >= atime
        valid = 1.years
      elsif mode < 2
        valid = 2.years
      else
        valid = 1.hours
      end

      @seeding._atime.set!(snvid, atime)

      parser = RmNvinfo.new(@sname, snvid, valid: valid)
      btitle, author = parser.btitle, parser.author
      next if btitle.empty? || author.empty?

      if @seeding._index.set!(snvid, [btitle, author])
        @seeding.set_intro(snvid, parser.bintro)
        @seeding.genres.set!(snvid, clean_genres(parser.genres))
        @seeding.bcover.set!(snvid, parser.bcover)
      end

      @seeding.status.set!(snvid, parser.status_int)

      if idx % 100 == 0
        puts "- [#{@sname}]: <#{idx}/#{upto}>"
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
    file = RmSpider.nvinfo_file(@sname, snvid)
    File.info?(file).try(&.modification_time.to_unix)
  end

  def seed!(mode = 0)
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
        bhash, _ = @seeding.set!(snvid, mode: mode)

        if NvValues.voters.ival(bhash) == 0
          NvValues.set_score(bhash, Random.rand(1..5), Random.rand(30..50))
        end
      end

      if idx % 100 == 0
        puts "- [#{@sname}] <#{idx}/#{input.size}>".colorize.blue
        Nvinfo.save!(mode: :upds)
      end
    rescue err
      puts err
      puts [snvid, vals]
      gets
    end

    Nvinfo.save!(mode: :full)
  end

  private def should_pick?(snvid : String)
    return true if @sname == "hetushu" || @sname == "rengshu"
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
    worker.prep!(upto) if mode > 0
    # worker.init!(upto, mode: mode)
    # worker.seed!(mode) if mode >= 0
  end
end

CV::Seeds::MapRemote.run!(ARGV)
