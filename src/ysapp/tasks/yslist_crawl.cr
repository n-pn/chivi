require "pg"
require "../../cv_env"

require "./_crawl_common"
require "../_raw/raw_ys_list"

class CV::YslistCrawl < CrawlTask
  # def db_seed_tasks(json : String)
  #   yslist = YS::Yslist.upsert!(self.oid, self.created_at || self.updated_at)

  #   yslist.ysuser = ysuser || begin
  #     user = self.user.not_nil!
  #     YS::Ysuser.upsert!(user.name, user._id)
  #   end

  #   yslist.set_name(self.zname)
  #   yslist.set_desc(self.zdesc)

  #   yslist.klass = klass
  #   yslist.stime = stime
  #   yslist.utime = self.updated_at.to_unix

  #   yslist.book_total = self.book_total if self.book_total > yslist.book_total
  #   yslist.like_count = self.like_count if self.like_count > yslist.like_count

  #   yslist.view_count = self.view_count if self.view_count > yslist.view_count
  #   yslist.star_count = self.star_count if self.star_count > yslist.star_count

  #   yslist.fix_sort!
  #   yslist.save!
  # rescue err
  #   Log.error { err.inspect_with_backtrace.colorize.red }
  # end
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

    uuids = DB.open(CV_ENV.database_url) do |db|
      stmt = "select origin_id from yslists"
      db.query_all(stmt, as: String)
    end

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
