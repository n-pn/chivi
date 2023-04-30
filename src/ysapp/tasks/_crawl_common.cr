require "pg"
require "json"
require "zstd"
require "http/client"
require "option_parser"

require "../../_util/hash_util"
require "../../_util/proxy_client"
require "../../cv_env"

PG_DB = DB.open(CV_ENV.database_url)
at_exit { PG_DB.close }

def read_zstd(path : String)
  file = File.open(path, "r")
  Zstd::Decompress::IO.open(file, sync_close: true, &.gets_to_end)
end

HEADERS = HTTP::Headers{"Content-Type" => "application/json"}

puts "contact server: #{CV_ENV.ys_host}"

def post_raw_data(href : String, body : String)
  HTTP::Client.post("#{CV_ENV.ys_host}/_ys/#{href}", headers: HEADERS, body: body) do |res|
    color = res.success? ? :green : :red
    puts res.body_io.gets_to_end.colorize(color)
  end
end

def file_exists?(file : String, span = 1.days)
  return false unless info = File.info?(file)
  info.modification_time > Time.utc - span
end

enum CrawlMode
  Head; Tail; Rand

  def rearrange!(queue)
    case self
    in Head then queue
    in Tail then queue.reverse!
    in Rand then queue.shuffle!
    end
  end
end

abstract class CrawlTask
  struct Entry
    getter link : String
    getter path : String
    getter name : String

    def initialize(@link, @path, @name = "-/-")
    end

    def existed?(ttl = 1.day)
      File.info?(@path).try(&.modification_time.> Time.utc - ttl) || false
    end
  end

  def initialize(reseed_proxies = false)
    @http = ProxyClient.new(reseed_proxies)
  end

  def crawl!(queue : Enumerable(Entry), loop_no = 1)
    return if queue.empty?

    qsize = queue.size
    wsize = qsize
    wsize = 8 if wsize > 8

    puts "- loop_no: #{loop_no}, entries: #{qsize}".colorize.cyan

    workers = Channel(Entry).new(qsize)
    results = Channel(Entry?).new(wsize)

    wsize.times do
      spawn do
        loop do
          break unless entry = workers.receive?
          results.send(crawl_entry!(entry))
        end
      end
    end

    queue.each { |entry| workers.send(entry) }

    fails = [] of Entry
    qsize.times { results.receive.try { |x| fails << x } }
    crawl!(fails, loop_no &+ 1)
  end

  def crawl_entry!(entry : Entry) : Entry?
    puts "- <#{entry.name.colorize.magenta}> GET: #{entry.link.colorize.magenta}"
    return entry unless json = @http.fetch!(entry.link, entry.name)

    save_raw_json(entry, json)
    db_seed_tasks(entry, json)

    nil
  rescue ex
    Log.error(exception: ex) { ex.colorize.red }
    entry
  end

  ZSTD = Zstd::Compress::Context.new(level: 3)

  private def save_raw_json(entry : Entry, json : String)
    File.write(entry.path, ZSTD.compress(json.to_slice))

    hash = HashUtil.encode32(HashUtil.fnv_1a(json))
    hash_path = entry.path.sub("latest", hash)

    File.copy(entry.path, hash_path) unless File.file?(hash_path)

    puts "  [#{entry.path}] saved.".colorize.green
  end

  abstract def db_seed_tasks(entry : Entry, json : String)

  def mkdirs!(queue : Enumerable(Entry))
    dirs = queue.map { |entry| File.dirname(entry.path) }.uniq!
    dirs.each { |dir| Dir.mkdir_p(dir) }
  end
end
