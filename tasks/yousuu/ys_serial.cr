require "json"
require "option_parser"

require "../shared/raw_ysbook"
require "./shared/http_client"

class CV::CrawlYsbook
  DIR = "_db/yousuu/infos"

  def initialize(regen_proxy = false)
    @http = HttpClient.new(regen_proxy)
  end

  def crawl!(upto = 260000, mode = :tail)
    queue = (1..upto).to_a.map(&.to_s)

    case mode
    when :tail then queue.reverse!
    when :rand then queue.shuffle!
    end

    count = 0

    until queue.empty?
      count += 1
      puts "\n[loop: #{count}, mode: #{mode}, size: #{queue.size}]".colorize.cyan

      fails = [] of String

      limit = queue.size
      limit = 15 if limit > 15
      inbox = Channel(String?).new(limit)

      queue.each_with_index(1) do |snvid, idx|
        exit(0) if @http.no_proxy?

        spawn do
          label = "<#{idx}/#{queue.size}> [#{snvid}]"
          inbox.send(crawl_info!(snvid, label: label))
        end

        inbox.receive.try { |snvid| fails << snvid } if idx > limit
      end

      limit.times do
        inbox.receive.try { |snvid| fails << snvid }
      end

      exit(0) if @http.no_proxy?
      queue = fails
    end
  end

  def crawl_info!(snvid : String, label = "1/1/1")
    group = (snvid.to_i // 1000).to_s.rjust(3, '0')
    file = "#{DIR}/#{group}/#{snvid}.json"

    return if still_good?(file)

    link = "https://api.yousuu.com/api/book/#{snvid}"
    return snvid unless @http.save!(link, file, label)
  end

  def still_good?(file : String)
    return false unless info = File.info?(file)
    info.modification_time + expiry_time(file) >= Time.utc
  end

  private def expiry_time(file : String) : Time::Span
    return 6.days unless data = CV::RawYsbook.load(file)

    span = 2.days
    # try again in 2 4 6 days
    span *= (data.status + 1)
    # try again in 4 8 12 days
    data.voters == 0 ? span * 2 : span
  rescue
    6.days
  end
end

recheck_proxy = false
crawl_mode = :tail
max_ysnvid = ENV["SNVID"]?.try(&.to_i) || 270388

OptionParser.parse(ARGV) do |opt|
  opt.on("-p", "Recheck proxies") { recheck_proxy = true }
  opt.on("-h", "Crawl from beginning") { crawl_mode = :head }
  opt.on("-r", "Crawl randomly") { crawl_mode = :rand }
end

recheck_proxy = ARGV.includes?("proxy")
worker = CV::CrawlYsbook.new(recheck_proxy)
worker.crawl!(max_ysnvid, mode: crawl_mode)
