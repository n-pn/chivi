require "json"
require "option_parser"

require "../shared/bootstrap"
require "../shared/http_client"
require "../shared/yscrit_raw"

class CV::YslistCrawl
  DIR = "_db/yousuu/list-books-by-score"
  Dir.mkdir_p(DIR)

  @lists = {} of String => Yslist

  def initialize(regen_proxy = false)
    @http = HttpClient.new(regen_proxy)
    @channel = Channel(String).new

    Yslist.query.order_by(id: :desc).each_with_cursor(20) do |yslist|
      crit_count = Yscrit.query.where({yslist_id: yslist.id}).count
      @lists[yslist.origin_id] = yslist if crit_count < yslist.book_total
    end
  end

  enum Mode
    Head; Tail; Rand
  end

  def crawl!(page = 1, mode : Mode = :head)
    queue = [] of Yslist

    @lists.each_value do |yslist|
      queue << yslist if yslist.book_total >= (page &- 1) &* 20
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

      fails = [] of Yslist

      limit = queue.size
      limit = 15 if limit > 15
      inbox = Channel(Yslist?).new(limit)

      queue.each_with_index(1) do |yslist, idx|
        exit(0) if @http.no_proxy?

        spawn do
          label = "<#{idx}/#{qsize}> [#{yslist.id}]"
          inbox.send(crawl_page!(yslist, page, label: label))
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

  FRESH = 2.days

  def crawl_page!(yslist : Yslist, page : Int32, label : String)
    origin_id = yslist.origin_id
    file = "#{DIR}/#{origin_id[0..3]}/#{origin_id}-#{page}.json"

    unless FileUtil.mtime(file).try { |x| x + FRESH * page > Time.utc }
      return yslist unless @http.save!(page_url(origin_id, page), file, label)
    end

    @channel.send(file)
    nil
  end

  def page_url(origin_id : String, page = 1)
    "https://api.yousuu.com/api/booklist/#{origin_id}?page=#{page}&sort=score&t=#{Time.utc.to_unix_ms}"
  end

  def seed_file!(file : String) : Nil
    stime = FileUtil.mtime(file).not_nil!.to_unix

    tuple = YscritRaw.from_list(File.read(file))

    origin_id = File.basename(file, ".json").split("-").first
    yslist = @lists[origin_id]

    tuple[:books].each(&.seed!(stime, yslist.id))

    yslist.update({
      book_total: tuple[:total],
      book_count: Yscrit.query.where({yslist_id: yslist.id}).count.to_i,
    })

    Log.info { "- yscrits: #{Yscrit.query.count}".colorize.cyan }
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
