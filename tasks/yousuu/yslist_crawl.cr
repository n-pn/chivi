require "json"
require "option_parser"

require "../shared/bootstrap"
require "../shared/http_client"
require "../shared/yslist_raw"

class CV::YslistCrawl
  DIR = "_db/yousuu/lists-by-book"
  Dir.mkdir_p(DIR)

  @books = {} of Int64 => Ysbook

  def initialize(regen_proxy = false)
    @http = HttpClient.new(regen_proxy)
    @channel = Channel(String).new

    Ysbook.query.order_by(id: :desc).each_with_cursor(20) do |ysbook|
      @books[ysbook.id] = ysbook if ysbook.list_count < ysbook.list_total
    end
  end

  enum Mode
    Head; Tail; Rand
  end

  def crawl!(page = 1, mode : Mode = :head)
    queue = [] of Ysbook

    @books.each_value do |ysbook|
      queue << ysbook if ysbook.list_total >= (page &- 1) &* 20
    end

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

      fails = [] of Ysbook

      limit = queue.size
      limit = 15 if limit > 15
      inbox = Channel(Ysbook?).new(limit)

      queue.each_with_index(1) do |ysbook, idx|
        exit(0) if @http.no_proxy?

        spawn do
          label = "<#{idx}/#{qsize}> [#{ysbook.id}]"
          inbox.send(crawl_page!(ysbook, page, label: label))
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

  FRESH = 1.days

  def crawl_page!(ysbook : Ysbook, page : Int32, label : String)
    file = "#{DIR}/#{ysbook.id}/#{page}.json"

    unless FileUtil.mtime(file).try { |x| x + FRESH * page > Time.utc }
      return ysbook unless @http.save!(page_url(ysbook.id, page), file, label)
    end

    @channel.send(file)
    nil
  end

  def page_url(book_id : Int64, page = 1)
    "https://api.yousuu.com/api/book/#{book_id}/booklist?page=#{page}&t=#{Time.utc.to_unix_ms}"
  end

  def seed_file!(file : String) : Nil
    stime = FileUtil.mtime(file).not_nil!.to_unix

    tuple = YslistRaw.from_list(File.read(file))

    ys_bid = File.basename(File.dirname(file)).to_i64
    ysbook = @books[ys_bid]

    tuple[:booklists].each(&.seed!(stime))

    ysbook.update({
      list_total: tuple[:total] > ysbook.list_total ? tuple[:total] : ysbook.list_total,
      list_count: Yscrit.query.where("ysbook_id = ? AND yslist_id > 0", ysbook.id).count.to_i,
    })

    Log.info { "- yslists: #{Yslist.query.count}".colorize.cyan }
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

    OptionParser.parse(ARGV) do |opt|
      opt.on("--proxy", "Recheck proxies") { recheck_proxy = true }
      opt.on("-m MODE", "Crawl mode") { |x| crawl_mode = Mode.parse(x) }
    end

    worker = new(recheck_proxy)
    1.upto(100) do |page|
      worker.crawl!(page, crawl_mode) unless worker.no_proxy?
    end
  end

  run!(ARGV)
end
