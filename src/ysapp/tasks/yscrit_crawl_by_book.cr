require "pg"
require "../../cv_env"

require "./_crawl_common"
require "../_raw/raw_yscrit"

class YS::CrawlYscritByBook < CrawlTask
  def db_seed_tasks(entry : Entry, json : String)
    return unless json.starts_with?('{')
    api_path = "crits/by_book?rtime=#{Time.utc.to_unix}"
    post_raw_data(api_path, json)
  end

  def self.gen_link(y_bid : Int32, page : Int32 = 1)
    "https://api.yousuu.com/api/book/#{y_bid}/comment?type=latest&page=#{page}"
  end

  DIR = "var/ysraw/crits-by-book"

  def self.gen_path(y_bid : Int32, page : Int32 = 1)
    "#{DIR}/#{y_bid}/#{page}.latest.json.zst"
  end

  ################

  def self.run!(argv = ARGV)
    start = 1
    reseed = false

    OptionParser.parse(argv) do |opt|
      opt.on("-p PAGE", "start page") { |i| start = i.to_i }
      opt.on("-r", "Reseed content") { reseed = true }
    end

    queue_init = gen_queue_init
    return if queue_init.empty?

    queue_init.each { |init| Dir.mkdir_p("#{DIR}/#{init.y_bid}") }

    max_pages = queue_init.max_of(&.pgmax)
    crawler = new(false)

    start.upto(max_pages) do |pg_no|
      queue_init.reject!(&.pgmax.< pg_no)

      queue = queue_init.map_with_index(1) do |init, index|
        Entry.new(
          link: gen_link(init.y_bid, pg_no),
          path: gen_path(init.y_bid, pg_no),
          name: "#{index}/#{queue_init.size}"
        )
      end

      expiry = pg_no * (pg_no - 1) // 2 + 1
      queue.reject!(&.existed?(expiry.days))
      crawler.crawl!(queue)
    end
  end

  record QueueInit, y_bid : Int32, pgmax : Int32

  def self.gen_queue_init
    PG_DB.exec <<-SQL
      update ysbooks set crit_count = (
        select count(*) from yscrits
        where ysbook_id = ysbooks.id
      ) where crit_total > 0;
    SQL

    select_stmt = <<-SQL
      select id, crit_total from ysbooks
      where crit_total > crit_count
      order by (crit_total - crit_count) desc
    SQL

    output = [] of QueueInit

    PG_DB.query_each(select_stmt) do |rs|
      y_bid, total = rs.read(Int32, Int32)
      pgmax = (total - 1) // 20 + 1
      output << QueueInit.new(y_bid, pgmax)
    end

    output
  end

  run!(ARGV)
end
