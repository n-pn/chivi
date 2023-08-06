require "pg"
require "../../cv_env"

require "./_crawl_common"
require "../../zroot/json_parser/raw_yscrit"

class CrawlYscritByUser < CrawlTask
  def db_seed_tasks(entry : Entry, json : String)
    return unless json.starts_with?('{')

    yl_id = File.basename(File.dirname(entry.path))
    rtime = Time.utc.to_unix

    api_path = "crits/by_list/#{yl_id}?rtime=#{rtime}"
    CrUtil.post_raw_data(api_path, json)
  end

  def self.gen_link(yl_id : String, page : Int32 = 1)
    "https://api.yousuu.com/api/booklist/#{yl_id}?page=#{page}"
  end

  DIR = "var/.keep/yousuu/crits-bylist"

  def self.gen_path(yl_id : String, page : Int32 = 1)
    "#{DIR}/#{yl_id}/#{page}-latest.json"
  end

  ################

  def self.run!(argv = ARGV)
    start = 1
    update = false
    reseed = false

    OptionParser.parse(argv) do |opt|
      opt.on("-p PAGE", "start page") { |i| start = i.to_i }
      opt.on("-r", "Reseed content") { reseed = true }
      opt.on("--update", "Update counters before run") { update = true }
    end

    fix_stats! if update

    queue_init = gen_queue_init
    return if queue_init.empty?

    queue_init.each { |init| Dir.mkdir_p("#{DIR}/#{init.yl_id}") }

    max_pages = queue_init.max_of(&.pgmax)
    crawler = new("yscrit_bylist", false)

    start.upto(max_pages) do |pg_no|
      queue_init.reject!(&.pgmax.< pg_no)

      queue = queue_init.map_with_index(1) do |init, index|
        Entry.new(
          link: gen_link(init.yl_id, pg_no),
          path: gen_path(init.yl_id, pg_no),
          name: "#{index}/#{queue_init.size}"
        )
      end

      expiry = pg_no * (pg_no - 1) // 2 + 1
      queue.reject!(&.cached?(expiry.days))
      crawler.crawl!(queue)

      `/app/chivi.app/bin/fix_yscrits_vhtml`
    end
  end

  def self.fix_stats!
    PGDB.exec <<-SQL
      update yslists set book_count = (
        select count(*)::int from yscrits
        where yscrits.yslist_id = yslists.id
      );
      SQL
  end

  record QueueInit, yl_id : String, pgmax : Int32

  SELECT_STMT = <<-SQL
    select encode(yl_id, 'hex'), book_total from yslists
    where book_total > book_count
    SQL

  def self.gen_queue_init(fix_db_stat : Bool = true)
    output = [] of QueueInit

    PGDB.query_each(SELECT_STMT) do |rs|
      yl_id, total = rs.read(String, Int32)
      output << QueueInit.new(yl_id, (total - 1) // 20 + 1)
    end

    output
  end

  run!(ARGV)
end
