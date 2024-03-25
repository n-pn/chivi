require "../shared/crawling"
require "../../zroot/json_parser/raw_yslist"

class YslistCrawl < CrawlTask
  def db_seed_tasks(entry : Entry, json : String)
    # TODO:
  end

  #####################

  def self.gen_link(uuid : String)
    "https://api.yousuu.com/api/booklist/#{uuid}/info"
  end

  DIR = "/srv/chivi/.keep/yousuu/list-infos"

  def self.gen_path(uuid : String)
    "#{DIR}/#{uuid}/latest.json"
  end

  def self.run!(argv = ARGV)
    crawl_mode = CrawlMode::Rand
    reseed = false

    OptionParser.parse(argv) do |opt|
      opt.on("-m MODE", "Crawl mode") { |x| crawl_mode = CrawlMode.parse(x) }
      opt.on("-r", "Reseed content") { reseed = true }
    end

    queue = gen_queue()
    queue.reject!(&.cached?(3.days))
    queue = crawl_mode.rearrange!(queue)

    crawler = new("yslist_info", false)
    crawler.mkdirs!(queue)

    crawler.crawl!(queue)
  end

  def self.gen_queue : Array(Entry)
    # fresh = Time.utc - ttl

    yl_ids = PGDB.query_all <<-SQL, as: String
      select encode(yl_id, 'hex') from yslists
      SQL

    yl_ids.map_with_index do |yl_id, index|
      Entry.new(
        link: gen_link(yl_id),
        path: gen_path(yl_id),
        name: "#{index}/#{yl_ids.size}"
      )
    end
  end

  run!(ARGV)
end
