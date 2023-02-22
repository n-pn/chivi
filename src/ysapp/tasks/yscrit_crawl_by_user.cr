require "./_crawl_common"

require "../_raw/raw_ys_crit"
require "../data/ys_user"

class YS::CrawlYscritByUser < CrawlTask
  # def crawl_page!(u_id : Int32, page : Int32 = 1, label = "-/-") : Int32?
  #   link = api_page_url(u_id, page)
  #   Log.info { "GET: #{link.colorize.magenta}" }

  #   out_path = "#{DIR}/#{u_id}/#{page}.json.zst"
  #   return if file_exists?(out_path, page.days)

  #   return u_id unless json = @client.fetch!(link, label)
  #   save_raw_json(u_id, json, out_path)

  #   # fields, values = RawYsBook.from_raw_json(json).changeset
  #   # YsBook.upsert!(fields, values)

  #   nil
  # rescue ex
  #   Log.error(exception: ex) { ex.colorize.red }
  #   u_id
  # end

  def self.gen_link(u_id : Int32, page : Int32 = 1)
    "https://api.yousuu.com/api/user/#{u_id}/comment?page=#{page}"
  end

  DIR = "var/ysraw/crits-by-user"

  def self.gen_path(u_id : Int32, page : Int32 = 1)
    "#{DIR}/#{u_id}/#{page}.latest.json.zst"
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

    queue_init.each { |init| Dir.mkdir_p("#{DIR}/#{init.id}") }

    max_pages = queue_init.max_of(&.pgmax)
    crawler = new(false)

    start.upto(max_pages) do |pg_no|
      queue_init.reject!(&.pgmax.< pg_no)

      queue = queue_init.map_with_index(1) do |init, index|
        Entry.new(
          link: gen_link(init.id, pg_no),
          path: gen_path(init.id, pg_no),
          name: "#{index}/#{queue_init.size}"
        )
      end

      queue.reject!(&.existed?(pg_no.days))
      crawler.crawl!(queue)
    end
  end

  record QueueInit, id : Int32, pgmax : Int32

  def self.gen_queue_init(min_ttl = 1.day)
    output = [] of QueueInit

    # fresh = (Time.utc - min_ttl).to_unix

    YsUser.open_db do |db|
      sql = <<-SQL
        select id, crit_total, crit_rtime from users
        order by (like_count + star_count) desc
        SQL

      db.query_each(sql) do |rs|
        id, total, _rtime = rs.read(Int32, Int32, Int64)

        # fresh -= 10 # add 1 second delay
        # next if rtime < fresh

        total = 1 if total < 1
        pages = (total - 1) // 20 + 1

        output << QueueInit.new(id, pages)
      end
    end

    output
  end

  run!(ARGV)
end
