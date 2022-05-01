require "../shared/http_client"
require "../shared/yslist_raw"

class CV::YslistCrawlByBook
  DIR = "_db/yousuu/lists-by-book"
  Dir.mkdir_p(DIR)

  enum CrMode
    Head; Tail; Rand
  end

  @http = HttpClient.new(ARGV.includes?("--refresh-proxy"))
  @data : Array(Ysbook)

  def initialize(crmode : CrMode, @reseed = false)
    @data = Ysbook.query.where("list_count < list_total").to_a

    case crmode
    when .rand? then @data.shuffle!
    when .tail? then @data.sort_by!(&.id.-)
    when .head? then @data.sort_by!(&.id)
    end
  end

  def crawl!(page = 1)
    queue = @data.select!(&.list_total.>= (page &- 1) &* 20)
    exit 0 if queue.empty?

    loops = 0

    until queue.empty?
      qsize = queue.size
      qnext = [] of Ysbook

      Log.info { "<#{page}> [loop: #{loops}, size: #{qsize}]".colorize.cyan }

      workers = qsize
      workers = 10 if workers > 10
      channel = Channel(Ysbook?).new(workers)

      queue.each_with_index(1) do |ysbook, idx|
        spawn do
          label = "[#{page}] <#{idx}/#{qsize}> [#{ysbook.id}]"
          channel.send(do_crawl!(ysbook, page, label: label))
        end

        channel.receive.try { |x| qnext << x } if idx > workers
      end

      workers.times do
        channel.receive.try { |x| qnext << x }
      end

      exit 0 if @http.no_proxy?
      queue = qnext
      loops += 1
    end
  end

  def do_crawl!(ysbook : Ysbook, page = 0, label = "-/-") : Ysbook?
    y_bid = ysbook.id
    ofile = "#{DIR}/#{y_bid}/#{page}.json"

    if FileUtil.fresh?(ofile, Time.utc - 2.days - 6.hours * page)
      return unless @reseed # skip seeding old data
    elsif !@http.save!(api_url(y_bid, page), ofile, label)
      return ysbook
    end

    lists, total = YslistRaw.from_list(File.read(ofile))

    stime = FileUtil.mtime_int(ofile)
    lists.each(&.seed!(stime))

    total = ysbook.list_total if ysbook.list_total > total
    count = Yscrit.query.where("ysbook_id = #{y_bid} AND yslist_id > 0").count.to_i

    ysbook.update(list_total: total, list_count: count)
    Log.info { "yslists: #{Yslist.query.count}".colorize.cyan }
  end

  def api_url(y_bid : Int64, page = 1)
    "https://api.yousuu.com/api/book/#{y_bid}/booklist?page=#{page}&t=#{Time.utc.to_unix_ms}"
  end

  #####################

  def self.run!(argv = ARGV)
    crmode = CrMode::Rand
    reseed = false

    OptionParser.parse(argv) do |opt|
      opt.on("-m MODE", "Crawl mode") { |x| crmode = CrMode.parse(x) }
      opt.on("-r", "Reseed content") { reseed = true }
    end

    worker = new(crmode, reseed)
    1.upto(100) { |page| worker.crawl!(page) }
  end

  run!(ARGV)
end
