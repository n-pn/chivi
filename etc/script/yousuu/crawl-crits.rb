require_relative "./crawl-utils"

class CritCrawler
  def initialize(load_proxy = false, debug_mode = false)
    @http = HttpClient.new(load_proxy, debug_mode)
    @ybids = []

    files = Dir.glob("var/appcv/book_metas/*.json")
    files.each do |file|
      json = JSON.parse(File.read(file))
      link = json["yousuu_link"]
      @ybids << File.basename(link) unless link.empty?
    end
  end

  def crawl!(page = 1)
    step = 1
    ybids = @ybids.dup

    until ybids.empty? || proxy_size == 0
      puts "\n[<#{step}-#{page}> ybids: #{ybids.size}, proxies: #{proxy_size}]".yellow
      fails = []

      Parallel.each_with_index(ybids, in_threads: 20) do |ybid, idx|
        out_file = page_path(ybid, page)
        next unless outdated?(out_file)

        case @http.get!(page_url(ybid, page), out_file)
        when :success
          puts " - <#{idx}/#{ybids.size}> [#{ybid}] saved.".green
        when :proxy_error
          puts " - <#{idx}/#{ybids.size}> [#{ybid}] proxy error!".red
          fails << ybid
        when :no_more_proxy
          puts " - Ran out of proxy, aborting!".red
          break
        end
      end

      step += 1
      ybids = fails
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
