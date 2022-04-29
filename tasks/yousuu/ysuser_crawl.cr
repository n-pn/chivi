require "../shared/http_client"
require "../shared/ysuser_raw"

class CV::YsuserCrawl
  DIR = "_db/yousuu/users"
  Dir.mkdir_p(DIR)

  enum CrMode
    Head; Tail; Rand
  end

  @http = HttpClient.new(false)
  @data : Array(Ysuser)

  def initialize(crmode : CrMode = :tail, @reseed = false)
    fresh = Time.utc - 7.days
    @data = Ysuser.query.where("origin_id > 0 AND stime < ?", fresh.to_unix).to_a

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
      qnext = [] of Ysuser

      Log.info { "[loop: #{loops}, size: #{qsize}]".colorize.cyan }

      qnext = [] of Ysuser

      workers = qsize
      workers = 10 if workers > 10
      channel = Channel(Ysuser?).new(workers)

      queue.each_with_index(1) do |ysuser, idx|
        exit(0) if @http.no_proxy?

        spawn do
          label = "<#{idx}/#{qsize}> [#{ysuser.id}]"
          channel.send(do_crawl!(ysuser, label: label))
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

  def do_crawl!(ysuser : Ysuser, label : String = "-/-") : Ysuser?
    y_uid = ysuser.origin_id
    ofile = "#{DIR}/#{y_uid}.json"

    if FileUtil.fresh?(ofile, Time.utc - 7.days)
      return unless @reseed # skip seeding old data
    elsif !@http.save!(api_url(y_uid), ofile, label)
      return ysuser
    end

    stime = FileUtil.mtime_int(ofile)
    YsuserRaw.from_info(File.read(ofile)).seed!(stime)

    Log.info { "- ysusers: #{Ysuser.query.where("crit_total > 0").count}".colorize.cyan }
  rescue err
    puts err
  end

  private def api_url(y_uid : Int32)
    "https://api.yousuu.com/api/user/#{y_uid}/info"
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
