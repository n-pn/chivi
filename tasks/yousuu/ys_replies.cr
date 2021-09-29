require "./shared/http_client"
require "../shared/raw_ysrepl"

class CV::CrawlYsrepl
  DIR = "_db/yousuu/repls"

  @max_pgs = {} of String => Int32

  def initialize(regen_proxy = false)
    @http = HttpClient.new(regen_proxy)

    Yscrit.query.order_by(id: :desc).each_with_cursor(20) do |yscrit|
      page_count = (yscrit.repl_count - 1) // 20 + 1
      @max_pgs[yscrit.origin_id] = page_count > 1 ? page_count : 1
    end
  end

  def crawl!(page = 1)
    count = 0
    queue = [] of String

    @max_pgs.each do |scrid, pgmax|
      queue << scrid if page <= pgmax
    end

    until queue.empty?
      count += 1
      puts "\n[page: #{page}, loop: #{count}, size: #{queue.size}]".colorize.cyan

      fails = [] of String

      limit = queue.size
      limit = 15 if limit > 15
      inbox = Channel(String?).new(limit)

      queue.each_with_index(1) do |string, idx|
        return if @http.no_proxy?

        spawn do
          label = "(#{page}) <#{idx}/#{queue.size}> [#{string}]"
          inbox.send(crawl_repl!(string, page, label: label))
        end

        inbox.receive.try { |string| fails << string } if idx > limit
      end

      limit.times do
        inbox.receive.try { |string| fails << string }
      end

      queue = fails
      break if @http.no_proxy?
    end
  end

  def crawl_repl!(scrid : String, page = 1, label = "1/1/1") : String?
    group = scrid[0..3]
    file = "#{DIR}/#{group}/#{scrid}-#{page}.json"

    return if still_fresh?(file, @max_pgs[scrid] - page)

    link = "https://api.yousuu.com/api/comment/#{scrid}/reply?&page=#{page}"
    return scrid unless @http.save!(link, file, label)

    total, repls = RawYsrepl.parse_raw(File.read(file))
    Yscrit.find!({origin_id: scrid}).update!(repl_count: total) if page == 1

    repls.each(&.seed!)
  rescue err
    puts err
  end

  REDO = ARGV.includes?("+redo")

  private def still_fresh?(file : String, page_desc = 1)
    return false if REDO

    return false unless info = File.info?(file)
    still_fresh = Time.utc - 10.day * page_desc
    info.modification_time >= still_fresh
  end

  delegate no_proxy?, to: @http
end

reload_proxy = ARGV.includes?("proxy")
worker = CV::CrawlYsrepl.new(reload_proxy)

1.upto(10) do |page|
  worker.crawl!(page) unless worker.no_proxy?
end
