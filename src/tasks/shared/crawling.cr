require "pg"
require "json"
require "xxhash"
require "http/client"
require "option_parser"

ENV["CV_ENV"] = "production" unless ARGV.includes?("--test")
require "../../cv_env"

PGDB = DB.open(CV_ENV.database_url)
at_exit { PGDB.close }

require "../shared/proxy_client"

HEADERS = HTTP::Headers{"Content-Type" => "application/json"}

module CrUtil
  extend self

  def post_raw_data(href : String, body : String)
    link = "#{CV_ENV.ys_host}/_ys/#{href}"
    HTTP::Client.post(link, headers: HEADERS, body: body) do |res|
      color = res.success? ? :green : :red
      puts res.body_io.gets_to_end.colorize(color)
    end
  end

  def file_exists?(fpath : String, tspan = 1.days)
    return false unless info = File.info?(fpath)
    info.modification_time > Time.utc - tspan
  end
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

    def cached?(tspan = 1.day)
      CrUtil.file_exists?(@path, tspan: tspan)
    end

    def parent
      File.basename(File.dirname(@path))
    end

    def save!(data : String, log_file : String)
      File.write(@path, data)

      uniq_name = XXHash.xxh32(data).to_s(base: 36)
      hash_path = @path.sub("latest", uniq_name)

      File.copy(@path, hash_path)
      File.open(log_file, "a", &.puts("#{hash_path}\t#{Time.utc.to_unix}"))

      Log.info { "  [#{@path}] saved.".colorize.green }
    end
  end

  CACHE_DIR = "var/.keep"

  def initialize(@task_name : String, reseed_proxies = false)
    @http = ProxyClient.new(reseed_proxies)
    @log_file = "#{CACHE_DIR}/.crlog/#{@task_name}.tsv"
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

  def read_entry_no_proxy(entry : Entry, tspan = 12.hours) : String?
    return File.read(entry.path) if entry.cached?(tspan: tspan)

    HTTP::Client.get(entry.link) do |res|
      return unless res.status.success?
      body = res.body_io.gets_to_end
      body.tap { |data| File.write(entry.path, data) }
    end
  end

  def crawl_entry!(entry : Entry) : Entry?
    puts "- <#{entry.name.colorize.magenta}> GET: #{entry.link.colorize.magenta}"

    if entry.cached?(tspan: 2.hours)
      json = File.read(entry.path)
    else
      json = @http.fetch!(entry.link, entry.name)
    end

    return entry unless json

    entry.save!(json, @log_file)
    db_seed_tasks(entry, json)

    nil
  rescue ex
    Log.error(exception: ex) { ex.colorize.red }
    entry
  end

  abstract def db_seed_tasks(entry : Entry, json : String)

  def mkdirs!(queue : Enumerable(Entry))
    dirs = queue.map { |entry| File.dirname(entry.path) }.uniq!
    dirs.each { |dir| Dir.mkdir_p(dir) }
  end
end
