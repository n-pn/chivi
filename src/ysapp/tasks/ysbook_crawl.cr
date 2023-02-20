require "./_crawl_common"
require "../_raw/raw_ys_book"
require "../data/ys_book"

class YS::CrawlYsbook < CrawlTask
  def db_seed_tasks(json : String)
    fields, values = RawYsBook.from_raw_json(json).changeset
    YsBook.upsert!(fields, values)
  end

  def self.gen_link(b_id : Int32)
    "https://api.yousuu.com/api/book/#{b_id}"
  end

  DIR = "var/ysraw/books"

  # Dir.mkdir_p(DIR)

  def self.gen_path(b_id : Int32)
    group = (b_id // 1000).to_s.rjust(3, '0')
    "#{DIR}/#{group}/#{b_id}.latest.json.zst"
  end

  #####

  def self.run!(argv = ARGV)
    min_id = 1
    max_id = 295362

    reseed_proxies = false
    crawl_mode = CrawlMode::Tail

    OptionParser.parse(argv) do |opt|
      opt.on("-f FROM", "From book id") { |x| min_id = x.to_i }
      opt.on("-u UPTO", "Upto book id") { |x| max_id = x.to_i }

      opt.on("--head", "Crawl from beginning") { crawl_mode = CrawlMode::Head }
      opt.on("--rand", "Crawl infos randomly") { crawl_mode = CrawlMode::Rand }

      opt.on("--reseed-proxies", "Refresh proxies from init lists") { reseed_proxies = true }
    end

    queue = gen_queue(min_id, max_id)
    queue = crawl_mode.rearrange!(queue)

    worker = new(reseed_proxies)
    worker.mkdirs!(queue)

    worker.crawl!(queue)
  end

  def self.gen_queue(min = 1, max = 100000)
    y_bids = Set(Int32).new(min..max)

    YsBook.open_db do |db|
      sql = "select id, cprio, ctime from books where id >= ? and id <= ?"

      db.query_each sql, min, max do |rs|
        id, cprio, ctime = rs.read(Int32, Int32, Int64)
        y_bids.delete(id) unless should_crawl?(cprio, ctime)
      end
    end

    y_bids.map_with_index(1) do |y_bid, index|
      Entry.new(
        link: gen_link(y_bid),
        path: gen_path(y_bid),
        name: "#{index}/#{y_bids.size}"
      )
    end
  end

  TIME_TO_STALE = {14.days, 10.days, 7.days, 5.days, 3.days, 1.days}

  def self.should_crawl?(cprio : Int32, ctime : Int64)
    return false if cprio < 0
    tspan = TIME_TO_STALE[cprio]? || 1.days
    Time.unix(ctime) + tspan < Time.utc
  end

  run!(ARGV)
end
