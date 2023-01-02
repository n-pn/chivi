require "json"
require "option_parser"

require "../filedb/ys_book"
require "../filedb/raw_ys_book"
require "../../_util/proxy_client"

class YS::CrawlYsbook
  def initialize(reseed_proxies = false)
    @client = ProxyClient.new(reseed_proxies)
  end

  def crawl!(queue : Array(Int32))
    dirs = Set(String).new
    queue.each { |x| dirs << group_dir(x) }
    dirs.each { |dir| Dir.mkdir_p("#{DIR}/#{dir}") }

    loops = 0

    until queue.empty?
      qsize = queue.size
      puts "\n[loop: #{loops}, size: #{qsize}]".colorize.cyan

      loops += 1
      fails = [] of Int32

      workers = qsize
      workers = 8 if workers > 8
      channel = Channel(Int32?).new(workers)

      queue.each_with_index(1) do |b_id, idx|
        exit 0 if @client.empty?

        spawn do
          label = "<#{idx}/#{qsize}> [#{b_id}]"
          channel.send(crawl_book!(b_id, label: label))
        end

        channel.receive.try { |x| fails << x } if idx > workers
      end

      workers.times { channel.receive.try { |x| fails << x } }
      queue = fails
    end
  end

  DIR = "var/ysraw/books"

  def crawl_book!(b_id : Int32, label = "-/-") : Int32?
    link = "https://api.yousuu.com/api/book/#{b_id}"
    return b_id unless json = @client.fetch!(link, label)

    File.write("#{DIR}/#{group_dir(b_id)}/#{b_id}.json", json)

    fields, values = RawYsBook.from_raw_json(json).changeset
    YsBook.upsert!(fields, values)

    nil
  rescue err
    Log.error { err.inspect_with_backtrace }
  end

  private def group_dir(b_id : Int32)
    (b_id // 1000).to_s.rjust(3, '0')
  end

  enum Mode
    Head; Tail; Rand
  end

  def self.run!(argv = ARGV)
    min_book_id = 1
    max_book_id = 270000

    reseed_proxies = false
    crawl_mode = Mode::Tail

    OptionParser.parse(argv) do |opt|
      opt.on("-f FROM", "From book id") { |x| min_book_id = x.to_i }
      opt.on("-u UPTO", "Upto book id") { |x| max_book_id = x.to_i }

      opt.on("--head", "Crawl from beginning") { crawl_mode = Mode::Head }
      opt.on("--rand", "Crawl infos randomly") { crawl_mode = Mode::Rand }

      opt.on("--reseed-proxies", "Refresh proxies from init lists") { reseed_proxies = true }
    end

    queue = generate_queue(min_book_id, max_book_id)

    case crawl_mode
    when .tail? then queue.reverse!
    when .rand? then queue.shuffle!
    end

    new(reseed_proxies).crawl!(queue)
  end

  def self.generate_queue(min = 1, max = 1)
    queue = Set(Int32).new(min..max)
    YsBook.open_db do |db|
      db.query_each "select id, cprio, ctime from books where id >= #{min} and id <= #{max}" do |rs|
        id, cprio, ctime = rs.read(Int32, Int32, Int64)
        queue.delete(id) unless should_crawl?(cprio, ctime)
      end
    end

    queue.to_a
  end

  TIME_TO_STALE = {14.days, 10.days, 7.days, 5.days, 3.days, 1.days}

  def self.should_crawl?(cprio : Int32, ctime : Int64)
    return false if cprio < 0
    tspan = TIME_TO_STALE[cprio]? || 1.days
    Time.unix(ctime) + tspan < Time.utc
  end

  run!(ARGV)
end
