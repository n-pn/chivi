require "zstd"
require "option_parser"

require "../_raw/raw_ys_crit"
require "../data/ys_user"

require "../../_util/hash_util"
require "../../_util/proxy_client"

class YS::CrawlYscritByUser
  def initialize(reseed_proxies = false)
    @client = ProxyClient.new(reseed_proxies)
  end

  def crawl!(queue : Array(Int32), page = 1, loops = 0)
    exit 0 if queue.empty? || @client.empty?

    qsize = queue.size
    wsize = qsize
    wsize = 8 if wsize > 8

    puts "- loop: #{loops}, size: #{qsize}"

    workers = Channel(Int32).new(qsize)
    results = Channel(Int32?).new(wsize)

    wsize.times do
      spawn do
        loop do
          # sleep 10.milliseconds
          break unless u_id = workers.receive?
          results.send(crawl_page!(u_id, page, label: "<#{qsize}> [#{u_id}]"))
        end
      end
    end

    queue.each { |id| workers.send(id) }

    fails = [] of Int32
    qsize.times { results.receive.try { |x| fails << x } }

    crawl!(fails, loops + 1)
  end

  def file_exists?(file : String, span = 1.days)
    return false unless info = File.info?(file)
    info.modification_time > Time.utc - span
  end

  DIR = "var/ysraw/crits-by-user"
  Dir.mkdir_p(DIR)

  def crawl_page!(u_id : Int32, page : Int32 = 1, label = "-/-") : Int32?
    link = api_page_url(u_id, page)
    Log.info { "GET: #{link.colorize.magenta}" }

    out_path = "#{DIR}/#{u_id}/#{page}.json.zst"
    return if file_exists?(out_path, page.days)

    return u_id unless json = @client.fetch!(link, label)
    save_raw_json(u_id, json, out_path)

    # fields, values = RawYsBook.from_raw_json(json).changeset
    # YsBook.upsert!(fields, values)

    nil
  rescue ex
    Log.error(exception: ex) { ex.colorize.red }
    u_id
  end

  ZSTD = Zstd::Compress::Context.new(level: 3)

  private def save_raw_json(u_id : Int32, json : String, fpath : String)
    File.write(fpath, ZSTD.compress(json.to_slice))

    hashed = HashUtil.fnv_1a(json)
    File.copy(fpath, fpath.sub(".json.zst", "#{hashed}.json.zst"))

    Log.info { "#{u_id} saved.".colorize.green }
  end

  private def api_page_url(u_id : Int32, page : Int32 = 1)
    "https://api.yousuu.com/api/user/#{u_id}/comment?page=#{page}&t=#{Time.utc.to_unix_ms}"
  end

  ################

  def self.run!(argv = ARGV)
    reseed_proxies = false

    OptionParser.parse(argv) do |opt|
      opt.on("--reseed-proxies", "Refresh proxies from init lists") { reseed_proxies = true }
    end

    queue = make_queue
    return if queue.empty?

    queue.each do |id, _|
      Dir.mkdir_p("#{DIR}/#{id}")
    end

    crawler = new(reseed_proxies)

    max_pages = queue.max_of(&.[1])

    1.upto(max_pages) do |page|
      queue = queue.reject!(&.[1].< page)
      crawler.crawl!(queue.map(&.[0]), page)
    end
  end

  def self.make_queue
    output = [] of {Int32, Int32}

    fresh = (Time.utc - 1.day).to_unix

    YsUser.open_db do |db|
      sql = <<-SQL
        select id, crit_total, crit_rtime from users
        order by (like_count + star_count) desc
        SQL

      db.query_each(sql) do |rs|
        id, total, rtime = rs.read(Int32, Int32, Int64)

        # fresh -= 10 # add 1 second delay
        # next if rtime < fresh

        total = 1 if total < 1
        pages = (total - 1) // 20 + 1

        output << {id, pages}
      end
    end

    output
  end

  run!(ARGV)
end
