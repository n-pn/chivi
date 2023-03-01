require "pg"
require "../../cv_env"

require "./_crawl_common"
require "../_raw/raw_ys_crit"

class YS::CrawlYscritByBook < CrawlTask
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

  SELECT_SQL = <<-SQL
    select id::int, crit_total from ysbooks
    -- where crit_total > crit_count
  SQL

  def self.gen_queue_init
    output = [] of QueueInit

    DB.open(CV_ENV.database_url) do |db|
      db.query_each(SELECT_SQL) do |rs|
        y_bid, total = rs.read(Int32, Int32)
        pgmax = (total - 1) // 20 + 1
        output << QueueInit.new(y_bid, pgmax)
      end
    end

    output
  end

  run!(ARGV)
end
