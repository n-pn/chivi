require "./_crawl_common"
require "../_raw/raw_ys_book"

class YS::CrawlYsbook < CrawlTask
  def db_seed_tasks(entry : Entry, json : String)
    return if json.includes?("未找到该图书")
    post_raw_data("/books/info", json)
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
    max_id = 296181

    reseed_proxies = false
    crawl_mode = CrawlMode::Tail

    OptionParser.parse(argv) do |opt|
      opt.on("-f FROM", "From book id") { |x| min_id = x.to_i }
      opt.on("-u UPTO", "Upto book id") { |x| max_id = x.to_i }

      opt.on("--head", "Crawl from beginning") { crawl_mode = CrawlMode::Head }
      opt.on("--rand", "Crawl infos randomly") { crawl_mode = CrawlMode::Rand }

      opt.on("--reseed-proxies", "Refresh proxies from init lists") { reseed_proxies = true }
    end

    queue = gen_queue(min_id, max_id).reject!(&.existed?(1.days))
    queue = crawl_mode.rearrange!(queue)

    worker = new(reseed_proxies)
    worker.mkdirs!(queue)

    worker.crawl!(queue)
  end

  def self.gen_queue(min = 1, max = 300000)
    y_bids = Set(Int32).new(min..max)

    select_stmt = <<-SQL
      select id, voters, info_rtime from ysbooks
      where id >= ? and id <= ?
    SQL

    PG_DB.query_each(select_stmt, min, max) do |rs|
      id, voters, rtime = rs.read(Int32, Int32, Int64)
      y_bids.delete(id) unless should_crawl?(voters, rtime)
    end

    y_bids.map_with_index(1) do |y_bid, index|
      Entry.new(
        link: gen_link(y_bid),
        path: gen_path(y_bid),
        name: "#{index}/#{y_bids.size}"
      )
    end
  end

  def self.should_crawl?(voters : Int32, rtime : Int64)
    tspan = map_tspan(voters)
    Time.unix(rtime) + tspan < Time.utc
  end

  def self.map_tspan(voters : Int32)
    case voters
    when .< 10   then 14.days
    when .< 50   then 10.days
    when .< 100  then 7.days
    when .< 300  then 5.days
    when .< 1000 then 3.days
    else              1.days
    end
  end

  run!(ARGV)
end
