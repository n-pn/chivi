require_relative "./crawl_utils"

class CritCrawler
  INFO_DIR = "var/.book_cache/yousuu/serials"

  def initialize(load_proxy = false, debug_mode = false)
    @http = HttpClient.new(load_proxy, debug_mode)
  end

  def book_path(ybid)
    File.join(INFO_DIR, "#{ybid}.json")
  end

  def book_url(ybid)
    time = (Time.now.to_f * 1000).round
    "https://www.yousuu.com/api/book/#{ybid}?t=#{time}"
  end

  EXPIRY = 3600 * 24 * 3 # 3 days

  def get_expiry_by_status(text)
    json = JSON.parse(text)

    status = json["data"]["bookInfo"]["status"] || 0
    expiry = EXPIRY * (status + 1) # bump to 6 days or 9 days

    score = json["data"]["bookInfo"]["score"] || 0
    expiry *= 3 if score == 0 # bump to 9, 12 or 18 days

    expiry
  end

  def outdated?(file)
    return true unless File.exists?(file)

    text = File.read(file)
    if text.include?("未找到该图书")
      expiry = EXPIRY * 5 # 15 days
    else
      expiry = get_expiry_by_status(text)
    end

    File.mtime(file).to_i < Time.now.to_i - expiry
  end

  def proxy_size
    @http.proxies.size
  end

  def crawl!(total = 212500, order = :sequel)
    puts "-- [total: #{total}, order: #{order}] --".yellow

    ybids = (1..total).to_a
    if order == :shuffle
      ybids.shuffle!
    elsif order == :reverse
      ybids.reverse!
    end

    step = 1
    until ybids.empty? || proxy_size == 0
      puts "\n[<#{step}> ybids: #{ybids.size}, proxies: #{proxy_size}]".yellow
      fails = []

      Parallel.each_with_index(ybids, in_threads: 20) do |ybid, idx|
        out_file = book_path(ybid)
        next unless outdated?(out_file)

        case @http.get!(book_url(ybid), out_file)
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
end

load_proxy = ARGV.include?("proxy")
debug_mode = ARGV.include?("debug")
crawler = CritCrawler.new(load_proxy, debug_mode)

total = (ARGV[0] || "212500").to_i || 212500

order = :sequel
order = :reverse if ARGV.include?("reverse")
order = :shuffle if ARGV.include?("shuffle")

crawler.crawl!(total, order)
