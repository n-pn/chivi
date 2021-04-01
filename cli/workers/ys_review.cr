require "./ys_common"

class Seeds::YsReview
  DIR = "_db/yousuu/.cache/crits"
  SRC = "_db/nv_infos/yousuu.tsv"

  @input : Array(String)

  def initialize(regen_proxy = false)
    @http = Client.new(regen_proxy)
    @input = File.read_lines(SRC).map(&.split('\t')[1])
  end

  def crawl!(page = 1)
    count = 0
    queue = @input.dup

    until queue.empty?
      count += 1
      puts "\n[page: #{page}, loop: #{count}, size: #{queue.size}]".colorize.cyan

      fails = [] of String

      limit = queue.size
      limit = 15 if limit > 15
      inbox = Channel(String?).new(limit)

      queue.each_with_index(1) do |snvid, idx|
        spawn do
          label = "(#{page}) <#{idx}/#{queue.size}> [#{snvid}]"
          inbox.send(crawl_crit!(snvid, page, label: label))
        end

        inbox.receive.try { |snvid| fails << snvid } if idx > limit
      end

      limit.times do
        inbox.receive.try { |snvid| fails << snvid }
      end

      queue = fails
      break if @http.no_proxy?
    end
  end

  def crawl_crit!(snvid : String, page = 1, label = "1/1/1") : String?
    file = "#{DIR}/#{snvid}-#{page}.json"
    return if still_good?(file, page)
    link = "https://api.yousuu.com/api/book/#{snvid}/comment?page=#{page}"
    return snvid unless @http.save!(link, file, label)
  end

  FRESH = 3.days

  private def still_good?(file : String, page = 1)
    return false unless info = File.info?(file)
    info.modification_time + FRESH * page > Time.utc
  end

  delegate no_proxy?, to: @http
end

worker = Seeds::YsReview.new(regen_proxy: ARGV.includes?("proxy"))

1.upto(4) do |page|
  worker.crawl!(page) unless worker.no_proxy?
end
