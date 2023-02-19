require "zstd"
require "option_parser"

require "../_raw/raw_ys_user"
require "../data/ys_user"

require "../../_util/hash_util"
require "../../_util/proxy_client"

class YS::CrawlYsuser
  def initialize(reseed_proxies = false)
    @client = ProxyClient.new(reseed_proxies)
  end

  def crawl!(queue : Array(Int32), loops = 0)
    qsize = queue.size
    wsize = qsize
    wsize = 8 if wsize > 8

    puts "- loop: #{loops}, size: #{qsize}"

    workers = Channel(Int32).new(qsize)
    results = Channel(Int32?).new(wsize)

    wsize.times do
      spawn do
        loop do
          # sleep 10.milliseconds
          break unless u_id = workers.receive?
          results.send(crawl_user!(u_id, label: "<#{qsize}> [#{u_id}]"))
        end
      end
    end

    queue.each { |id| workers.send(id) }

    fails = [] of Int32
    qsize.times { results.receive.try { |x| fails << x } }

    crawl!(fails, loops + 1)
  end

  UPSERT_SQL = YsUser.upsert_sql(YsUser::RAW_UPSERT_FIELDS)

  def crawl_user!(u_id : Int32, label = "-/-") : Int32?
    link = "https://api.yousuu.com/api/user/#{u_id}/info"

    Log.info { "GET: #{link.colorize.magenta}" }
    return u_id unless json = @client.fetch!(link, label)

    save_raw_json(u_id, json)

    args = RawYsUser.from_raw_json(json).changeset
    YsUser.open_tx(&.exec(UPSERT_SQL, args: args))

    nil
  rescue ex
    Log.error(exception: ex) { ex.colorize.red }
    u_id
  end

  ZSTD = Zstd::Compress::Context.new(level: 3)

  DIR = "var/ysraw/users"
  Dir.mkdir_p(DIR)

  private def save_raw_json(u_id : Int32, json : String)
    fname = "#{u_id}-#{HashUtil.fnv_1a(json)}.json.zst"
    File.write("#{DIR}/#{fname}", ZSTD.compress(json.to_slice))
    Log.info { "user info #{u_id} saved.".colorize.green }
  end

  #####################

  def self.run!(argv = ARGV)
    reseed_proxies = false

    OptionParser.parse(argv) do |opt|
      opt.on("--reseed-proxies", "Refresh proxies from init lists") { reseed_proxies = true }
    end

    queue = make_queue
    new(reseed_proxies).crawl!(queue)
  end

  def self.make_queue
    output = [] of Int32

    fresh = (Time.utc - 1.day).to_unix

    YsUser.open_db do |db|
      sql = <<-SQL
        select id, rtime from users
        order by (like_count + star_count) desc
        SQL

      db.query_each(sql) do |rs|
        id, rtime = rs.read(Int32, Int64)
        fresh -= 60 # add 1 minute
        output << id if rtime < fresh
      end
    end

    output
  end

  run!(ARGV)
end
