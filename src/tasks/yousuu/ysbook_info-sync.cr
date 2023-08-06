require "lexbor"
require "../../zroot/ysbook"
require "./_crawl_common"

class CrawlYsbook < CrawlTask
  def db_seed_tasks(entry : Entry, json : String)
    return unless json.starts_with?('{')

    spawn do
      CrUtil.post_raw_data("books/info", json)
      ysbook = ZR::Ysbook.from_raw_json(json)

      loop do
        ZR::Ysbook.open_tx { |db| ysbook.upsert!(db) }
        break
      rescue ex
        puts ex.message.colorize.red
        sleep 1.seconds
        next
      end
    end
  end

  def self.gen_link(yb_id : Int32)
    "https://api.yousuu.com/api/book/#{yb_id}"
  end

  DIR = "var/.keep/yousuu/book-infos"
  Dir.mkdir_p(DIR)

  def self.gen_path(yb_id : Int32)
    "#{DIR}/#{yb_id}/latest.json"
  end

  #####

  def self.run!(argv = ARGV)
    min_id = 1
    max_id = 0

    reseed_proxies = false
    crawl_mode = CrawlMode::Tail

    OptionParser.parse(argv) do |opt|
      opt.on("-f FROM", "From book id") { |x| min_id = x.to_i }
      opt.on("-u UPTO", "Upto book id") { |x| max_id = x.to_i }

      opt.on("--head", "Crawl from beginning") { crawl_mode = CrawlMode::Head }
      opt.on("--rand", "Crawl infos randomly") { crawl_mode = CrawlMode::Rand }

      opt.on("--reseed-proxies", "Refresh proxies from init lists") { reseed_proxies = true }
    end

    max_id = get_max_book_id(load_index_page(4.hours)) if max_id == 0
    puts "MIN: #{min_id}, MAX: #{max_id}"

    queue = gen_queue(min_id, max_id).reject!(&.cached?(12.hours))
    queue = crawl_mode.rearrange!(queue)

    worker = new("ysbook_info", reseed_proxies)
    worker.mkdirs!(queue)
    worker.crawl!(queue)
  end

  SELECT_STMT = <<-SQL
    select id, voters, rtime from ysbooks
    where id >= $1 and id <= $2
    SQL

  def self.gen_queue(min = 1, max = 300000)
    y_bids = Set(Int32).new(min..max)

    ZR::Ysbook.open_db do |db|
      db.query_each(SELECT_STMT, min, max) do |rs|
        id, voters, rtime = rs.read(Int32, Int32, Int64)
        y_bids.delete(id) unless should_crawl?(voters, rtime)
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

  def self.load_index_page(ttl = 4.hours)
    out_path = "var/.keep/_index/yousuu.htm"

    unless CrUtil.file_exists?(out_path, ttl)
      href = "https://www.yousuu.com/newbooks"
      html = HTTP::Client.get(href, &.body_io.gets_to_end)
      File.write(out_path, html)
    end

    html || File.read(out_path)
  end

  def self.get_max_book_id(html_page = load_index_page)
    page = Lexbor::Parser.new(html_page)
    node = page.css(".book-info > .book-name").first
    href = node.attributes["href"]
    File.basename(href).to_i
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
