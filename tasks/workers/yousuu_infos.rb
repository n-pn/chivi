require_relative "./yousuu_utils"

class InfoCrawler
  INFO_DIR = "_db/.cache/yousuu/infos"

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

  INTERVAL = 3600 * 24 * 2 # 2 days

  def still_good?(file)
    return false unless File.exists?(file)

    data = File.read(file)
    if data.include?("未找到该图书")
      interval = INTERVAL * 5 # try again in 10 days
    else
      interval = get_interval_by_status(data)
    end

    Time.now.to_i - File.mtime(file).to_i < interval
  end

  def get_interval_by_status(data)
    json = JSON.parse(data)

    status = json["data"]["bookInfo"]["status"] || 0
    interval = INTERVAL * (status + 1) # try again in 4 days or 6 days if completed or axed

    score = json["data"]["bookInfo"]["score"] || 0
    interval *= 3 if score == 0 # try again in 6, 8 or 12 days if no score

    interval
  end

  def proxy_size
    @http.proxies.size
  end

  def crawl!(total = 212500, order = :latest)
    puts "-- [total: #{total}, order: #{order}] --".yellow

    queue = (1..total).to_a
    if order == :random
      queue.shuffle!
    elsif order == :latest
      queue.reverse!
    end

    step = 1
    until queue.empty? || proxy_size == 0
      puts "\n[<#{step}> queue: #{queue.size}, proxies: #{proxy_size}]".yellow
      fails = []

      Parallel.each_with_index(queue, in_threads: 25) do |ybid, idx|
        out_file = book_path(ybid)
        next if still_good?(out_file)

        case @http.get!(book_url(ybid), out_file)
        when :success
          puts " - <#{idx}/#{queue.size}> [#{ybid}] saved.".green
        when :proxy_error
          puts " - <#{idx}/#{queue.size}> [#{ybid}] proxy failed, remain: #{proxy_size}.".red
          fails << ybid
        when :no_more_proxy
          puts " - Ran out of proxy, aborting!".red
        end
      end

      step += 1
      queue = fails
    end
  end
end

load_proxy = ARGV.include?("proxy")
debug_mode = ARGV.include?("debug")
crawler = InfoCrawler.new(load_proxy, debug_mode)

total = 249000

order = :latest
order = :oldest if ARGV.include?("oldest")
order = :random if ARGV.include?("random")

crawler.crawl!(total, order)
