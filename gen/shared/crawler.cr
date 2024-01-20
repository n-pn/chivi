require "json"
require "xxhash"
require "option_parser"

require "../../src/_util/http_util"

module CrawlUtil
  def self.file_saved?(fpath : String, tspan = 1.days)
    return false unless info = File.info?(fpath)
    info.modification_time >= Time.utc - tspan
  end
end

struct CrawlItem
  getter slink : String
  getter fpath : String
  getter label : String

  getter cbody : String { File.read(fpath) }

  def initialize(@slink, @fpath, @label = "-/-")
  end

  def saved?(tspan = 1.day)
    CrawlUtil.file_saved?(@fpath, tspan: tspan)
  end

  def save!(@cbody : String)
    Dir.mkdir_p(File.dirname(@fpath))
    File.write(@fpath, cbody)

    hash_fpath = @fpath.sub("latest", XXHash.xxh32(cbody).to_s(base: 36))
    File.copy(@fpath, hash_fpath)

    Log.info { "<#{@label}> [#{@fpath}] saved.".colorize.green }
  end
end

enum CrawlMode
  Head; Tail; Rand

  def rearrange!(queue : Enumerable)
    case self
    in Head then queue
    in Tail then queue.reverse!
    in Rand then queue.shuffle!
    end
  end
end

abstract class CrawlTask
  CACHE_DIR = "var/.keep"

  property headers : HTTP::Headers? = nil

  def initialize(@task_name : String,
                 @tspan = 1.days,
                 @encoding = "UTF-8",
                 @use_proxy : Bool = true)
    @cache_dir = "#{CACHE_DIR}/#{@task_name}"
  end

  abstract def make_link(item_id : Int32)

  def temp_path(item_id : Int32)
    "#{@cache_dir}/#{item_id}/latest.json"
  end

  def gen_queue(input : Enumerable(Int32), cmode : CrawlMode = :head)
    case cmode
    when .tail? then input.reverse!
    when .rand? then input.shuffle!
    end

    input.map_with_index(1) do |item_id, index|
      CrawlItem.new(
        slink: make_link(item_id),
        fpath: temp_path(item_id),
        label: "#{@task_name}: #{index}/#{input.size}"
      )
    end
  end

  def crawl_all(queue : Array(CrawlItem), loop_no = 1, threads = 8)
    return if queue.empty?

    puts "- loop_no: #{loop_no}, entries: #{queue.size}".colorize.cyan

    threads = queue.size if threads > queue.size
    results = Channel(CrawlItem?).new(threads)
    pending = Channel(CrawlItem).new(queue.size)

    threads.times do |i|
      spawn do
        sleep (i * 10).milliseconds

        loop do
          break unless item = pending.receive?
          results.send(crawl_one(item))
        end
      end
    end

    fails = [] of CrawlItem

    queue.each { |item| pending.send(item) }
    queue.size.times { results.receive.try { |item| fails << item } }

    crawl_all(fails, loop_no &+ 1) unless fails.empty?
  end

  def crawl_one(item : CrawlItem)
    Log.info { "<#{item.label}> GET: #{item.slink.colorize.magenta}" }

    unless item.saved?(tspan: @tspan)
      data = HttpUtil.fetch(item.slink, encoding: @encoding, headers: headers, use_proxy: @use_proxy)
      item.save!(data)
    end

    run_after_crawl_one(item)
  rescue ex
    Log.error(exception: ex) { item.slink.colorize.red }
    item
  end

  def run_after_crawl_one(item : CrawlItem)
    # DO SOMETHING HERE
  end
end
