require "../shared/crawling"
require "../../zroot/tubook"

class TubookSync < CrawlTask
  def db_seed_tasks(entry : Entry, json : String)
    # TODO
  end

  def self.gen_link(tn_id : Int32)
    "https://pre-api.tuishujun.com/api/getBookDetail?book_id=#{tn_id}"
  end

  DIR = "var/.keep/tuishu/book-details"
  Dir.mkdir_p(DIR)

  def self.gen_path(tn_id : Int32)
    "#{DIR}/#{tn_id}/latest.json"
  end

  #####

  def self.run!(argv = ARGV)
    min_id = 1
    max_id = 0

    reseed_proxies = false
    crawl_mode = CrawlMode::Head

    OptionParser.parse(argv) do |opt|
      opt.on("-f FROM", "From book id") { |x| min_id = x.to_i }
      opt.on("-u UPTO", "Upto book id") { |x| max_id = x.to_i }

      opt.on("--head", "Crawl foward") { crawl_mode = CrawlMode::Head }
      opt.on("--rand", "Crawl randomly") { crawl_mode = CrawlMode::Rand }
      opt.on("--tail", "Crawl backward") { crawl_mode = CrawlMode::Tail }

      opt.on("--reseed-proxies", "Refresh proxies from init lists") { reseed_proxies = true }
    end

    max_id = get_max_book_id(load_index_json(4.hours)) if max_id == 0
    puts "MIN: #{min_id}, MAX: #{max_id}"

    queue = gen_queue(min_id, max_id).reject!(&.cached?(12.hours))
    queue = crawl_mode.rearrange!(queue)

    worker = new("tubooks_info", reseed_proxies)
    worker.mkdirs!(queue)
    worker.crawl!(queue)
  end

  SELECT_STMT = <<-SQL
    select id, voters, rtime from tubooks
    where id >= $1 and id <= $2
    SQL

  def self.gen_queue(min = 1, max = 300000)
    tn_ids = Set(Int32).new(min..max)

    ZR::Tubook.open_db do |db|
      db.query_each(SELECT_STMT, min, max) do |rs|
        id, voters, rtime = rs.read(Int32, Int32, Int64)
        tn_ids.delete(id) unless should_crawl?(voters, rtime)
      end
    end

    tn_ids.map_with_index(1) do |y_bid, index|
      Entry.new(
        link: gen_link(y_bid),
        path: gen_path(y_bid),
        name: "#{index}/#{tn_ids.size}"
      )
    end
  end

  def self.load_index_json(tspan = 4.hours)
    out_path = "var/.keep/_index/tuishu.json"

    unless CrUtil.file_exists?(out_path, tspan)
      href = "https://pre-api.tuishujun.com/api/listBookRank?rank_type=new_book&page=1&pageSize=10"
      html = HTTP::Client.get(href, &.body_io.gets_to_end)
      File.write(out_path, html)
    end

    html || File.read(out_path)
  end

  def self.get_max_book_id(json_data = load_index_json) : Int32
    data = NamedTuple(data: Array(NamedTuple(book_id: Int32))).from_json(json_data, root: "data")
    new_max = data[:data].max_of(&.[:book_id])

    old_max = ZR::Tubook.open_db(&.query_one "select max(id) from tubooks", as: Int32)

    {old_max, new_max}.max
  end

  def self.should_crawl?(voters : Int32, rtime : Int64)
    tspan = map_tspan(voters)
    Time.unix(rtime) + tspan < Time.utc
  end

  def self.map_tspan(voters : Int32)
    case voters
    when .< 10  then 7.days
    when .< 50  then 5.days
    when .< 100 then 3.days
    when .< 200 then 2.days
    else             1.days
    end
  end

  run!(ARGV)
end
