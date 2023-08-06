require "pg"
require "../../cv_env"

require "./_crawl_common"
require "../../zroot/json_parser/raw_yslist"

class YslistCrawlByBook < CrawlTask
  def db_seed_tasks(entry : Entry, json : String, hash : UInt32)
    return unless json.starts_with?('{')
    CrUtil.post_raw_data("lists/info", json)

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
  end

  #####################

  def self.gen_link(ybid : Int32, page = 1)
    "https://api.yousuu.com/api/book/#{ybid}/booklist?page=#{page}"
  end

  DIR = "var/.keep/yousuu/lists-bybook"

  def self.gen_path(ybid : Int32, page = 1)
    "#{DIR}/#{ybid}/#{page}-latest.json"
  end

  def self.run!(argv = ARGV)
    crawl_mode = CrawlMode::Rand
    reseed = false

    OptionParser.parse(argv) do |opt|
      opt.on("-m MODE", "Crawl mode") { |x| crawl_mode = CrawlMode.parse(x) }
      opt.on("-r", "Reseed content") { reseed = true }
    end

    queue_init = gen_queue_init(crawl_mode)
    return if queue_init.empty?

    queue_init.each { |init| Dir.mkdir_p("#{DIR}/#{init.ybid}") }

    max_pages = queue_init.max_of(&.pgmax)
    crawler = new(false)

    crawler = new(false)

    1.upto(max_pages) do |page|
      queue_init.reject!(&.pgmax.< page)

      queue = queue_init.map_with_index(1) do |init, index|
        Entry.new(
          link: gen_link(init.ybid, page),
          path: gen_path(init.ybid, page),
          name: "#{index}/#{queue_init.size}"
        )
      end

      queue.reject!(&.existed?(page.days))
      crawler.crawl!(queue)
    end
  end

  record QueueInit, ybid : Int32, pgmax : Int32

  SELECT_STMT = <<-SQL
    select id, list_total from ysbooks
    where list_count < list_total
    order by id desc
    SQL

  def self.gen_queue_init(crawl_mode : CrawlMode = :head)
    output = [] of QueueInit

    PGDB.query_each(SELECT_STMT) do |rs|
      ybid, total = rs.read(Int32, Int32)

      total = 1 if total < 1
      pages = (total - 1) // 20 + 1

      output << QueueInit.new(ybid, pages)
    end

    crawl_mode.rearrange!(output)
  end

  run!(ARGV)
end
