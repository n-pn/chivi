require "set"
require "json"
require "time"
require "open-uri"
require "parallel"
require "colorize"
require "fileutils"

require_relative "./crawl-utils"

class CritCrawler
  def initialize(load_proxy = false, debug_mode = false)
    @http = HttpClient.new(load_proxy, debug_mode)
    @bids = []

    files = Dir.glob("var/appcv/book_metas/*.json")
    files.each do |file|
      json = JSON.parse(File.read(file))
      link = json["yousuu_link"]
      @bids << File.basename(link) unless link.empty?
    end
  end

  def load_bids(page = 1)
    @bids.each_with_object([]) do |ybid, memo|
      memo << ybid if outdated?(page_path(ybid, page))
    end
  end

  def crawl!(page = 1)
    puts "-- [ page: #{page} ] --".yellow

    step = 1
    bids = load_bids(page)

    until bids.empty? || proxy_size == 0
      puts "\n- <#{step}> ybids: #{bids.size}, proxies: #{proxy_size}\n".yellow
      failures = []

      Parallel.each_with_index(bids, in_threads: 20) do |ybid, idx|
        case @http.get!(page_url(ybid, page), page_path(ybid, page))
        when :success
          puts " - <#{idx}/#{bids.size}> [#{ybid}] saved.".green
        when :proxy_error
          puts " - <#{idx}/#{bids.size}> [#{ybid}] proxy error!".red
          failures << ybid
        when :no_more_proxy
          puts " - Ran out of proxy, aborting!".red
          return
        end
      end

      step += 1
      bids = failures
    end
  end

  def proxy_size
    @http.proxies.size
  end

  ROOT_DIR = "var/appcv/.cache/yousuu/reviews"

  def page_path(ybid, page = 1)
    "#{ROOT_DIR}/#{ybid}-#{page}.json"
  end

  EXPIRY = 3600 * 24 * 5

  def outdated?(file)
    return true unless File.exists?(file)
    expiry = EXPIRY

    data = File.read(file)
    expiry *= 4 if data.include?("未找到该图书")

    File.mtime(file).to_i < Time.now.to_i - expiry
  end

  def page_url(ybid, page = 1)
    time = (Time.now.to_f * 1000).round
    "https://www.yousuu.com/api/book/#{ybid}/comment?page=#{page}&t=#{time}"
  end
end

load_proxy = ARGV.include?("proxy")
debug_mode = ARGV.include?("debug")
crawler = CritCrawler.new(load_proxy, debug_mode)

page = 1
while crawler.proxy_size > 0
  crawler.crawl!(page)
  page += 1
end
