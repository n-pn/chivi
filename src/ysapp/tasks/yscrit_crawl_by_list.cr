require "pg"
require "../../cv_env"

require "./_crawl_common"
require "../_raw/raw_ys_crit"

class YS::CrawlYscritByUser < CrawlTask
  def db_seed_tasks(entry : Entry, json : String)
    return unless json.starts_with?('{')

    y_lid = File.basename(File.dirname(entry.path))
    rtime = Time.utc.to_unix

    api_path = "/_ys/crits/by_list/#{y_lid}?rtime=#{rtime}"
    post_raw_data(api_path, json)
  end

  def self.gen_link(y_lid : String, page : Int32 = 1)
    "https://api.yousuu.com/api/booklist/#{y_lid}?page=#{page}"
  end

  DIR = "var/ysraw/crits-by-list"

  def self.gen_path(y_lid : String, page : Int32 = 1)
    "#{DIR}/#{y_lid}/#{page}.latest.json.zst"
  end

  ################

  def self.run!(argv = ARGV)
    start = 1
    fix_db_stat = true
    reseed = false

    OptionParser.parse(argv) do |opt|
      opt.on("-p PAGE", "start page") { |i| start = i.to_i }
      opt.on("-r", "Reseed content") { reseed = true }
      opt.on("--nofix", "Do not caculate book_count before run") { fix_db_stat = false }
    end

    queue_init = gen_queue_init(fix_db_stat)
    return if queue_init.empty?

    queue_init.each { |init| Dir.mkdir_p("#{DIR}/#{init.y_lid}") }

    max_pages = queue_init.max_of(&.pgmax)
    crawler = new(false)

    start.upto(max_pages) do |pg_no|
      queue_init.reject!(&.pgmax.< pg_no)

      queue = queue_init.map_with_index(1) do |init, index|
        Entry.new(
          link: gen_link(init.y_lid, pg_no),
          path: gen_path(init.y_lid, pg_no),
          name: "#{index}/#{queue_init.size}"
        )
      end

      expiry = pg_no * (pg_no - 1) // 2 + 1
      queue.reject!(&.existed?(expiry.days))
      crawler.crawl!(queue)
    end
  end

  record QueueInit, y_lid : String, pgmax : Int32

  FIX_STAT_SQL = <<-SQL
    update yslists set book_count = (
      select count(*) from yscrits
      where yslist_id = yslists.id
    );
  SQL

  def self.gen_queue_init(fix_db_stat : Bool = true)
    PG_DB.exec(FIX_STAT_SQL) if fix_db_stat

    select_smt = <<-SQL
      select y_lid, book_total from yslists
      where book_total > book_count
    SQL

    output = [] of QueueInit

    PG_DB.query_each(select_smt) do |rs|
      y_lid, total = rs.read(String, Int32)
      output << QueueInit.new(y_lid, (total - 1) // 20 + 1)
    end

    output
  end

  run!(ARGV)
end
