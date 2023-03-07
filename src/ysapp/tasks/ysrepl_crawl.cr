require "./_crawl_common"
require "../_raw/raw_ys_repl"

class YS::CrawlYslistByUser < CrawlTask
  private def db_seed_tasks(entry : Entry, json : String)
    return unless json.starts_with?('{')
    post_raw_data("/_ys/repls/by_crit?rtime=#{Time.utc.to_unix}", json)
  rescue ex
    puts entry.path, json
    Log.error { ex.message }
  end

  def self.gen_link(y_cid : String, page : Int32 = 1)
    "https://api.yousuu.com/api/comment/#{y_cid}/reply?&page=#{page}"
  end

  DIR = "var/ysraw/repls"

  def self.gen_path(y_cid : String, page : Int32 = 1)
    "#{DIR}/#{y_cid}/#{page}.latest.json.zst"
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

    queue_init.each { |init| Dir.mkdir_p("#{DIR}/#{init.y_cid}") }

    max_pages = queue_init.max_of(&.pgmax)
    crawler = new(false)

    start.upto(max_pages) do |pg_no|
      queue_init.reject!(&.pgmax.< pg_no)

      queue = queue_init.map_with_index(1) do |init, index|
        Entry.new(
          link: gen_link(init.y_cid, pg_no),
          path: gen_path(init.y_cid, pg_no),
          name: "#{index}/#{queue_init.size}"
        )
      end

      expiry = pg_no * (pg_no - 1) // 2 + 1
      queue.reject!(&.existed?(expiry.days))
      crawler.crawl!(queue)
    end
  end

  record QueueInit, y_cid : String, pgmax : Int32

  def self.gen_queue_init(min_ttl = 1.day)
    output = [] of QueueInit

    # fresh = (Time.utc - min_ttl).to_unix

    PG_DB.exec <<-SQL
      update yscrits set repl_count = (
        select count(*) from ysrepls
        where yscrit_id = yscrits.id
      ) where repl_total > 0;
    SQL

    sql = <<-SQL
      select origin_id, repl_total from yscrits
      where repl_total > repl_count
      order by repl_total desc
    SQL

    PG_DB.query_each(sql) do |rs|
      id, total = rs.read(String, Int32)

      total = 1 if total < 1
      pages = (total - 1) // 20 + 1

      output << QueueInit.new(id, pages)
    end

    output
  end

  run!(ARGV)
end
