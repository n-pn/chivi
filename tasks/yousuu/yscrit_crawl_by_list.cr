require "../shared/http_client"
require "../shared/yscrit_raw"

class CV::YscritCrawlByList
  DIR = "_db/yousuu/crits-by-list"
  Dir.mkdir_p(DIR)

  enum CrMode
    Head; Tail; Rand
  end

  @http = HttpClient.new(ARGV.includes?("--refresh-proxy"))
  @data : Array(YS::Yslist)

  def initialize(@crmode : CrMode, @reseed = false)
    @data = YS::Yslist.query.where("book_count < book_total").to_a

    case crmode
    when .rand? then @data.shuffle!
    when .tail? then @data.sort_by!(&.id.-)
    when .head? then @data.sort_by!(&.id)
    end
  end

  def crawl!(page = 1)
    queue = @data.select!(&.book_total.>= (page &- 1) &* 20)
    exit 0 if queue.empty?

    loops = 0

    until queue.empty?
      qsize = queue.size
      qnext = [] of YS::Yslist

      Log.info { "<#{page}> [loop: #{loops}, size: #{qsize}]".colorize.cyan }

      workers = qsize
      workers = 10 if workers > 10
      channel = Channel(YS::Yslist?).new(workers)

      queue.each_with_index(1) do |yslist, idx|
        spawn do
          label = "[#{page}] <#{idx}/#{qsize}> [#{yslist.origin_id}]"
          channel.send(do_crawl!(yslist, page, label: label))
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

  def do_crawl!(yslist : YS::Yslist, page = 1, label = "-/-") : YS::Yslist?
    y_lid = yslist.origin_id
    ofile = "#{DIR}/#{y_lid[0..3]}/#{y_lid}-#{page}.json"

    if FileUtil.fresh?(ofile, Time.utc - 3.days - 6.hours * page)
      return unless @reseed # skip seeding old data
    elsif !@http.save!(api_url(y_lid, page), ofile, label)
      return yslist
    end

    crits, total = YscritRaw.from_list(File.read(ofile))

    stime = FileUtil.mtime_int(ofile)
    crits.each(&.seed!(stime, yslist.id))

    total = yslist.book_total if yslist.book_total > total
    count = YS::Yscrit.query.where(yslist_id: yslist.id).count.to_i

    yslist.update(book_total: total, book_count: count)
    Log.info { "yscrits: #{YS::Yscrit.query.count}".colorize.cyan }
  rescue err
    Log.error { err }
  end

  private def api_url(y_lid : String, page : Int32 = 1)
    "https://api.yousuu.com/api/booklist/#{y_lid}?page=#{page}&t=#{Time.utc.to_unix_ms}"
  end

  ################

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
