require "../shared/crawler"
require "../../src/wnapp/data/tubook"

class TubookReload < CrawlTask
  def make_link(item_id : Int32)
    "https://pre-api.tuishujun.com/api/getBookDetail?book_id=#{item_id}"
  end

  def temp_path(item_id : Int32)
    "#{@cache_dir}/#{item_id // 1000}/#{item_id}/latest.json"
  end

  def self.max_book_id : Int32
    old_max = WN::Tubook.db.query_one("select max(id) from tubooks", as: Int32)
    {old_max, 388745}.max
  end

  SELECT_STMT = <<-SQL
  select id, voters, rtime from tubooks
  where id >= $1 and id <= $2
  SQL

  def self.book_ids_to_crawl(min = 1, max = 300000)
    tn_ids = Set(Int32).new(min..max)

    WN::Tubook.db.open_ro do |db|
      db.query_each(SELECT_STMT, min, max) do |rs|
        id, voters, rtime = rs.read(Int32, Int32, Int64)
        tn_ids.delete(id) if Time.unix(rtime) >= Time.utc - crawl_tspan(voters)
      end
    end

    tn_ids.to_a
  end

  def self.crawl_tspan(voters : Int32)
    case voters
    when .< 5   then 64.days
    when .< 10  then 32.days
    when .< 50  then 16.days
    when .< 100 then 8.days
    when .< 200 then 4.days
    else             2.days
    end
  end
end

#####

min_id = 1
max_id = 0

cr_mode = CrawlMode::Head
threads = 8

OptionParser.parse(ARGV) do |opt|
  opt.on("-f FROM", "From book id") { |x| min_id = x.to_i }
  opt.on("-u UPTO", "Upto book id") { |x| max_id = x.to_i }
  opt.on("-c THREADS", "concurrent threads") { |x| threads = x.to_i }

  opt.on("--head", "Crawl foward") { cr_mode = CrawlMode::Head }
  opt.on("--rand", "Crawl randomly") { cr_mode = CrawlMode::Rand }
  opt.on("--tail", "Crawl backward") { cr_mode = CrawlMode::Tail }
end

max_id = TubookReload.max_book_id if max_id == 0
puts "MIN: #{min_id}, MAX: #{max_id}"

threads = 1 if threads < 1

ctask = TubookReload.new("tuishu/tubooks")
b_ids = TubookReload.book_ids_to_crawl(min_id, max_id)
queue = ctask.gen_queue(b_ids, cr_mode)
ctask.crawl_all(queue, threads: threads)
