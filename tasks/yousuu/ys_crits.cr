require "./ys_utils"

class CV::YsCrits
  DIR = "_db/yousuu/.cache/crits"
  SRC = "_db/nv_infos/yousuu.tsv"

  @input : Array(String)

  def initialize(regen_proxy = false)
    @http = Client.new(regen_proxy)
    @input = File.read_lines(SRC).map(&.split('\t')[1])
  end

  def crawl!(page = 1)
    count = 1
    queue = @input.dup

    until queue.empty?
      puts "\n[<#{count}-#{page}> queue: #{queue.size}]".colorize.cyan

      fails = [] of String

      limit = queue.size
      limit = 15 if limit > 15
      inbox = Channel(Nil).new(limit)

      queue.each_with_index(1) do |snvid, idx|
        spawn do
          crawl_crit!(snvid, page, label: "#{idx}/#{queue.size}/#{page}")
          inbox.send(nil)
        end

        inbox.receive if idx > limit
      end

      limit.times { inbox.receive }
      count += 1
      queue = fails
    end
  end

  def can_continue?
    @http.size > 0
  end

  def crawl_crit!(nvid : String, page = 1, label = "1/1/1")
    file = "#{DIR}/#{nvid}-#{page}.json"
    return if still_good?(file, page)

    link = "https://api.yousuu.com/api/book/#{nvid}/comment?page=#{page}"

    case @http.save!(link, file)
    when :ok
      puts "- <#{label}> [#{nvid}] saved".colorize.green
    when :err
      puts "- <#{label}> [#{nvid}] proxy failed, remain: #{@http.size}".colorize.yellow
    when :no_proxy
      puts " - Out of proxy, aborting!".colorize.red
    end
  end

  FRESH = 15.days

  def still_good?(file : String, page = 1)
    return false unless info = File.info?(file)
    info.modification_time + FRESH * page > Time.utc
  end
end

worker = CV::YsCrits.new(regen_proxy: ARGV.includes?("proxy"))

1.upto(4) do |page|
  worker.crawl!(page) if worker.can_continue?
end
