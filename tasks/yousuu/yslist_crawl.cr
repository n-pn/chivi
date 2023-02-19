require "../shared/http_client"
require "../shared/yslist_raw"

class CV::YslistCrawl
  DIR = "_db/yousuu/lists"
  Dir.mkdir_p(DIR)

  enum CrMode
    Head; Tail; Rand
  end

  @http = HttpClient.new(ARGV.includes?("--refresh-proxy"))
  @data : Array(YS::Yslist)

  def initialize(crmode : CrMode = :tail, @reseed = false)
    fresh = Time.utc - 3.days
    @data = YS::Yslist.query.where("stime < #{fresh.to_unix}").to_a

    case crmode
    when .rand? then @data.shuffle!
    when .head? then @data.sort_by!(&.id)
    when .tail? then @data.sort_by!(&.id.-)
    end
  end

  def crawl!
    queue = @data
    exit 0 if queue.empty?

    loops = 0

    until queue.empty?
      qsize = queue.size
      qnext = [] of YS::Yslist

      Log.info { "[loop: #{loops}, size: #{qsize}]".colorize.cyan }

      qnext = [] of YS::Yslist

      workers = qsize
      workers = 10 if workers > 10
      channel = Channel(YS::Yslist?).new(workers)

      queue.each_with_index(1) do |yslist, idx|
        exit(0) if @http.no_proxy?

        spawn do
          label = "<#{idx}/#{qsize}> [#{yslist.id}]"
          channel.send(do_crawl!(yslist, label: label))
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

  def do_crawl!(yslist : YS::Yslist, label : String = "-/-") : YS::Yslist?
    y_lid = yslist.origin_id
    ofile = "#{DIR}/#{y_lid}.json"

    if FileUtil.fresh?(ofile, Time.utc - 3.days)
      return unless @reseed # skip seeding old data
    elsif !@http.save!(api_url(y_lid), ofile, label)
      return yslist
    end

    stime = FileUtil.mtime_int(ofile)
    YslistRaw.from_info(File.read(ofile)).seed!(stime)

    Log.info { "yslists: #{YS::Yslist.query.where("zdesc != ''").count}".colorize.cyan }
  rescue err
    puts err
  end

  private def api_url(y_lid : String)
    "https://api.yousuu.com/api/booklist/#{y_lid}/info"
  end

  #####################

  def self.run!(argv = ARGV)
    crmode = CrMode::Rand
    reseed = false

    OptionParser.parse(argv) do |opt|
      opt.on("-m MODE", "Crawl mode") { |x| crmode = CrMode.parse(x) }
      opt.on("-r", "Reseed content") { reseed = true }
    end

    new(crmode, reseed).crawl!
  end

  run!(ARGV)
end
