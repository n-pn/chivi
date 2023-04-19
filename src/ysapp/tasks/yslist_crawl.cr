require "./_crawl_common"
require "../_raw/raw_yslist"

class YS::YslistCrawl < CrawlTask
  def db_seed_tasks(entry : Entry, json : String)
  end

  #   yslist = YS::Yslist.upsert!(self.oid, self.created_at || self.updated_at)

  #   yslist.ysuser = ysuser || begin
  #     user = self.user.not_nil!
  #     YS::Ysuser.upsert!(user.name, user._id)
  #   end

  # rescue err
  #   Log.error { err.inspect_with_backtrace.colorize.red }
  # end

  #####################

  def self.gen_link(uuid : String)
    "https://api.yousuu.com/api/booklist/#{uuid}/info"
  end

  DIR = "var/ysraw/lists"

  def self.gen_path(uuid : String)
    group = uuid[0..3]
    "#{DIR}/#{group}/#{uuid}.latest.json"
  end

  def self.run!(argv = ARGV)
    crawl_mode = CrawlMode::Rand
    reseed = false

    OptionParser.parse(argv) do |opt|
      opt.on("-m MODE", "Crawl mode") { |x| crawl_mode = CrawlMode.parse(x) }
      opt.on("-r", "Reseed content") { reseed = true }
    end

    queue = gen_queue()
    queue.reject!(&.existed?(3.days))
    queue = crawl_mode.rearrange!(queue)

    crawler = new(false)
    crawler.mkdirs!(queue)

    crawler.crawl!(queue)
  end

  def self.gen_queue : Array(Entry)
    # fresh = Time.utc - ttl

    uuids = PG_DB.query_all("select encode(yl_id, 'hex') from yslists", as: String)

    uuids.map_with_index do |uuid, index|
      Entry.new(
        link: gen_link(uuid),
        path: gen_path(uuid),
        name: "#{index}/#{uuids.size}"
      )
    end
  end

  run!(ARGV)
end
