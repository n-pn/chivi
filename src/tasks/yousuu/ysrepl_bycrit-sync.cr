require "../shared/crawling"
require "../../zroot/json_parser/raw_ysrepl"

class CrawlYslistByUser < CrawlTask
  private def db_seed_tasks(entry : Entry, json : String)
    return unless json.starts_with?('{')
    href = "repls/by_crit/#{entry.parent}?rtime=#{Time.utc.to_unix}"
    CrUtil.post_raw_data(href, json)
  end

  def self.gen_link(yc_id : String, page : Int32 = 1)
    "https://api.yousuu.com/api/comment/#{yc_id}/reply?page=#{page}"
  end

  DIR = "/srv/chivi/.keep/yousuu/repls-bycrit"

  def self.gen_path(yc_id : String, page : Int32 = 1)
    "#{DIR}/#{yc_id}/#{page}-latest.json"
  end

  ################

  def self.run!(argv = ARGV)
    start = 1
    reseed = false
    update = false

    OptionParser.parse(argv) do |opt|
      opt.on("-p PAGE", "start page") { |i| start = i.to_i }
      opt.on("--reseed", "Reseed content") { reseed = true }
      opt.on("--update", "update counter") { update = true }
    end

    update_counters! if update

    queue_init = gen_queue_init
    return if queue_init.empty?

    queue_init.each { |init| Dir.mkdir_p("#{DIR}/#{init.yc_id}") }

    max_pages = queue_init.max_of(&.pgmax)
    crawler = new("ysrepl_bycrit", reseed)

    start.upto(max_pages) do |pg_no|
      queue_init.reject!(&.pgmax.< pg_no)
      break if queue_init.empty?

      queue = queue_init.map_with_index(1) do |init, index|
        Entry.new(
          link: gen_link(init.yc_id, pg_no),
          path: gen_path(init.yc_id, pg_no),
          name: "#{index}/#{queue_init.size}"
        )
      end

      queue.reject!(&.cached?((2 + pg_no).days))
      crawler.crawl!(queue)
      spawn { `/2tb/app.chivi/bin/fix_ysrepls_vhtml` }
    end
  end

  def self.update_counters!
    PGDB.exec <<-SQL
      update yscrits set repl_count = (
        select count(*)::int from ysrepls
        where yscrit_id = yscrits.id
      ) where repl_total > 0;
    SQL
  end

  record QueueInit, yc_id : String, pgmax : Int32

  SELECT_STMT = <<-SQL
    select encode(yc_id, 'hex'), repl_total from yscrits
    where repl_count < repl_total
    order by repl_total desc
    SQL

  def self.gen_queue_init(min_ttl = 1.day)
    output = [] of QueueInit

    PGDB.query_each(SELECT_STMT) do |rs|
      yc_id, total = rs.read(String, Int32)

      next if yc_id.size != 24 || yc_id == "5ab33469f51f55f11cbac13b"
      output << QueueInit.new(yc_id, (total &- 1) // 20 &+ 1)
    end

    output
  end

  run!(ARGV)
end
