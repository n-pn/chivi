require "../shared/http_client"
require "../shared/ysrepl_raw"

class CV::CrawlYsrepl
  DIR = "_db/yousuu/repls"

  @crits = {} of Int64 => Yscrit

  def initialize(regen_proxy = false, @redo = false)
    @http = HttpClient.new(regen_proxy)

    Yscrit.query.order_by(id: :desc).each_with_cursor(20) do |yscrit|
      @crits[yscrit.id] = yscrit if yscrit.repl_count < yscrit.repl_total
    end
  end

  def crawl!(page = 1)
    count = 0
    queue = [] of Yscrit

    @crits.each_value do |yscrit|
      queue << yscrit if yscrit.repl_total >= (page &- 1) &* 20
    end

    until queue.empty?
      count += 1
      qsize = queue.size
      puts "\n[page: #{page}, loop: #{count}, size: #{queue.size}]".colorize.cyan

      fails = [] of Yscrit

      limit = queue.size
      limit = 15 if limit > 15
      inbox = Channel(Yscrit?).new(limit)

      queue.each_with_index(1) do |yscrit, idx|
        return if @http.no_proxy?

        spawn do
          label = "(#{page}) <#{idx}/#{qsize}> [#{yscrit.id}]"
          inbox.send(crawl_repl!(yscrit, page, label: label))
        end

        inbox.receive.try { |x| fails << x } if idx > limit
      end

      limit.times do
        inbox.receive.try { |x| fails << x }
      end

      queue = fails
      break if @http.no_proxy?
    end
  end

  def crawl_repl!(yscrit : Yscrit, page = 1, label = "-/-") : Yscrit?
    origin_id = yscrit.origin_id

    group = origin_id[0..3]
    file = "#{DIR}/#{group}/#{origin_id}-#{page}.json"

    pgmax = (yscrit.repl_count &- 1) // 20 &+ 1
    unless still_fresh?(file, pgmax &- page)
      link = "https://api.yousuu.com/api/comment/#{origin_id}/reply?&page=#{page}"
      return yscrit unless @http.save!(link, file, label)
    end

    json = YsreplRaw.from_list(File.read(file))

    stime = File.info(file).modification_time.to_unix
    json[:commentReply].each(&.seed!(stime: stime))

    yscrit.update!(
      repl_total: yscrit.repl_total > json[:total] ? yscrit.repl_total : json[:total],
      repl_count: Ysrepl.query.where("yscrit_id = ?", yscrit.id).count.to_i
    )
  rescue err
    puts err
  end

  FRESH = 5.days

  private def still_fresh?(file : String, page_desc = 1)
    return false if @redo || !(info = File.info?(file))
    info.modification_time >= Time.utc - FRESH * page_desc
  end

  delegate no_proxy?, to: @http

  #############

  def self.run!(argv = ARGV)
    worker = new(argv.includes?("-p"), redo: argv.includes?("--redo"))

    1.upto(20) do |page|
      worker.crawl!(page) unless worker.no_proxy?
    end
  end

  run!
end
