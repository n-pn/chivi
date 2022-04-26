require "json"
require "option_parser"

require "../shared/bootstrap"
require "../shared/http_client"
require "../shared/yslist_raw"

class CV::YslistCrawl
  DIR = "_db/yousuu/list-infos"
  Dir.mkdir_p(DIR)

  @queue = [] of Yslist

  def initialize(regen_proxy = false)
    @http = HttpClient.new(regen_proxy)
    @channel = Channel(String).new

    Yslist.query.order_by(id: :desc).each_with_cursor(20) do |yslist|
      @queue << yslist if yslist.zdesc.empty?
    end
  end

  enum Mode
    Head; Tail; Rand
  end

  def crawl!(mode : Mode = :head)
    case mode
    when .tail? then @queue.reverse!
    when .rand? then @queue.shuffle!
    end

    done = false

    spawn do
      loop do
        break if done

        select
        when file = @channel.receive
          seed_file!(file)
        when timeout(1.second)
          sleep 1.second
        end
      end
    end

    loops = 0

    until @queue.empty?
      qsize = @queue.size

      puts "\n[loop: #{loops}, mode: #{mode}, size: #{qsize}]".colorize.cyan

      fails = [] of Yslist

      limit = @queue.size
      limit = 15 if limit > 15
      inbox = Channel(Yslist?).new(limit)

      @queue.each_with_index(1) do |yslist, idx|
        exit(0) if @http.no_proxy?

        spawn do
          label = "<#{idx}/#{qsize}> [#{yslist.id}]"
          inbox.send(crawl_info!(yslist, label: label))
        end

        inbox.receive.try { |x| fails << x } if idx > limit
      end

      limit.times do
        inbox.receive.try { |x| fails << x }
      end

      return if @http.no_proxy?
      @queue = fails
      loops += 1
    end

    done = true
  end

  def crawl_info!(yslist : Yslist, label : String)
    origin_id = yslist.origin_id
    file = "#{DIR}/#{origin_id}.json"

    unless File.exists?(file)
      return yslist unless @http.save!(api_url(origin_id), file, label)
    end

    @channel.send(file)
    nil
  end

  def api_url(origin_id : String)
    "https://api.yousuu.com/api/booklist/#{origin_id}/info"
  end

  def seed_file!(file : String) : Nil
    stime = FileUtil.mtime(file).not_nil!.to_unix
    YslistRaw.from_info(File.read(file)).seed!(stime)
    Log.info { "- yslists: #{Yslist.query.where("zdesc != ''").count}".colorize.cyan }
  rescue err : JSON::ParseException
    puts err
    File.delete(file)
  rescue err
    puts err
  end

  delegate no_proxy?, to: @http

  def self.run!(argv = ARGV)
    crawl_mode = Mode::Rand
    recheck_proxy = false

    OptionParser.parse(argv) do |opt|
      opt.on("--proxy", "Recheck proxies") { recheck_proxy = true }
      opt.on("-m MODE", "Crawl mode") { |x| crawl_mode = Mode.parse(x) }
    end

    new(recheck_proxy).crawl!(crawl_mode)
  end

  run!(ARGV)
end
