require "json"
require "option_parser"

require "../shared/bootstrap"
require "../shared/http_client"
require "../shared/yslist_raw"

class CV::YslistCrawl
  DIR = "_db/yousuu/lists"
  Dir.mkdir_p(DIR)

  def initialize(regen_proxy = false, @type = "man", @screen = "comprehensive")
    @http = HttpClient.new(regen_proxy)

    @channel = Channel(String).new
  end

  enum Mode
    Head; Tail; Rand
  end

  def crawl!(limit = 20, mode : Mode = :head)
    queue = (1..limit).to_a

    case mode
    when .tail? then queue.reverse!
    when .rand? then queue.shuffle!
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

    until queue.empty?
      qsize = queue.size

      puts "\n[loop: #{loops}, mode: #{mode}, size: #{qsize}]".colorize.cyan

      fails = [] of Int32

      limit = queue.size
      limit = 15 if limit > 15
      inbox = Channel(Int32?).new(limit)

      queue.each_with_index(1) do |snvid, idx|
        exit(0) if @http.no_proxy?

        spawn do
          label = "<#{idx}/#{qsize}> [#{snvid}]"
          inbox.send(crawl_page!(snvid, label: label))
        end

        inbox.receive.try { |x| fails << x } if idx > limit
      end

      limit.times do
        inbox.receive.try { |x| fails << x }
      end

      return if @http.no_proxy?
      queue = fails
      loops += 1
    end

    done = true
  end

  def page_url(page = 1)
    "https://api.yousuu.com/api/booklists?type=#{@type}&screen=#{@screen}&page=#{page}&t=#{Time.utc.to_unix_ms}"
  end

  def crawl_page!(page : Int32, label : String)
    file = "#{DIR}/#{@type}-#{@screen}/#{page}.json"

    unless FileUtil.mtime(file).try { |x| x + 12.hours > Time.utc }
      return page unless @http.save!(page_url(page), file, label)
    end

    @channel.send(file)
    nil
  end

  def seed_file!(file : String) : Nil
    stime = FileUtil.mtime(file).not_nil!.to_unix
    lists = YslistRaw.parse_list(File.read(file))
    lists.each(&.seed!(stime))

    Log.info { "- yslists: #{Yslist.query.count}".colorize.cyan }
  rescue err : JSON::ParseException
    puts err
    File.delete(file)
  rescue err
    puts err
  end

  def self.run!(argv = ARGV)
    crawl_mode = Mode::Tail
    recheck_proxy = false

    type = "man"
    screen = "comprehensive"

    page_limit = 732

    OptionParser.parse(ARGV) do |opt|
      opt.on("--proxy", "Recheck proxies") { recheck_proxy = true }
      opt.on("-m MODE", "Crawl mode") { |x| crawl_mode = Mode.parse(x) }
      opt.on("-u LIMIT", "Page limit") { |x| page_limit = x.to_i }
      opt.on("-t TYPE", "List type") { |x| type = x }
      opt.on("-s SCREEN", "List screen") { |x| screen = x }
    end

    worker = new(recheck_proxy, type, screen)
    worker.crawl!(page_limit, crawl_mode)
  end

  run!(ARGV)
end
