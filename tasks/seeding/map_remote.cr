require "file_utils"
require "option_parser"

require "../../src/seeds/rm_nvinfo"
require "./_seeding.cr"

class CV::Seeds::MapRemote
  def initialize(@sname : String)
    @meta = Seeding.new(@sname)
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

      if mode < 2 || @meta._index.has_key?(snvid)
        next if @meta._index.ival_64(snvid) >= atime
        valid = 1.years
      elsif mode < 2
        valid = 2.years
      else
        valid = 1.hours
      end

      parser = RmNvInfo.new(@sname, snvid, valid: valid)
      btitle, author = parser.btitle, parser.author

      if @meta._index.set!(snvid, [atime.to_s, btitle, author])
        @meta.set_intro(snvid, parser.bintro)
        @meta.genres.set!(snvid, clean_genres(parser.genres))
        @meta.bcover.set!(snvid, parser.bcover)
      end

      @meta.update.set!(snvid, parser.update_int)
      @meta.status.set!(snvid, parser.status_int)

      if idx % 100 == 0
        puts "- [#{@sname}]: <#{idx}/#{upto}>"
        @meta.save!(clean: false)
      end
    rescue err
      puts err.colorize.red
    end

    @meta.save!(clean: true)
  end

  private def clean_genres(input : Array(String))
    input.map do |genre|
      genre == "轻小说" ? genre : genre.sub(/小说$/, "")
    end
  end

  private def access_time(snvid : String) : Int64?
    file = RmSpider.nvinfo_file(@sname, snvid)
    Seeding.get_atime(file)
  end

  def seed!(mode = 0)
    input = {} of Tuple(String, String) => String

    @meta._index.data.each do |snvid, infos|
      _, btitle, author = infos

      author = NvAuthor.fix_zh_name(author, btitle)
      btitle = NvBtitle.fix_zh_name(btitle, author)

      tuple = {btitle, author}
      next if input[tuple]?.try(&.to_i.> snvid.to_i)

      input[tuple] = snvid
    end

    input.each_with_index(1) do |(tuple, snvid), idx|
      btitle, author = tuple

      if should_pick?(snvid) || NvAuthor.exists?(author)
        bhash, _, _ = @meta.upsert!(snvid, fixed: true)
        if NvOrders.get_voters(bhash) == 0
          NvOrders.set_scores!(bhash, Random.rand(10..30), Random.rand(50..70))
        end

        @meta.upsert_chinfo!(bhash, snvid, mode: mode)
      end

      if idx % 100 == 0
        puts "- [#{@sname}] <#{idx}/#{input.size}>".colorize.blue
        NvInfo.save!(clean: false)
      end
    rescue err
      puts err
    end

    NvInfo.save!(clean: false)
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
    worker.init!(upto, mode: mode)
    worker.seed!(mode) if mode >= 0
  end
end

CV::Seeds::MapRemote.run!(ARGV)
