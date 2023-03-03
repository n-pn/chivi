require "./_crawl_common"

require "../_raw/raw_ys_list"
require "../data/ys_user"

class YS::CrawlYslistByUser < CrawlTask
  alias RawData = NamedTuple(data: NamedTuple(total: Int32))

  private def db_seed_tasks(entry : Entry, json : String)
    return unless json.starts_with?('{')

    # _crits, total = RawYsCrit.from_book_json(json)
    total = RawData.from_json(json)[:data][:total]
    yu_id = File.basename(File.dirname(entry.path)).to_i

    YsUser.open_db(&.exec YsUser::STATS_UPDATE_SQL, total, Time.utc.to_unix, yu_id)
  rescue ex
    puts entry.path, json
    Log.error { ex.message }
  end

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

      expiry = pg_no * (pg_no - 1) // 2 + 1
      queue.reject!(&.existed?(expiry.days))
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
