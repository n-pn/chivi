require "../shared/http_client"
require "../shared/yslist_raw"

class CV::YslistCrawlByUser
  DIR = "_db/yousuu/lists-by-user"
  Dir.mkdir_p(DIR)

  enum CrMode
    Head; Tail; Rand
  end

  @http = HttpClient.new(false)
  @data : Array(Ysuser)

  def initialize(crmode : CrMode, @reseed = false)
    @data = Ysuser.query.where("origin_id > 0 AND list_count < list_total").to_a

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
      qnext = [] of Ysuser

      Log.info { "<#{page}> [loop: #{loops}, size: #{qsize}]".colorize.cyan }

      workers = qsize
      workers = 10 if workers > 10
      channel = Channel(Ysuser?).new(workers)

      queue.each_with_index(1) do |ysuser, idx|
        spawn do
          label = "[#{page}] <#{idx}/#{qsize}> [#{ysuser.id}]"
          channel.send(do_crawl!(ysuser, page, label: label))
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

  def do_crawl!(ysuser : Ysuser, page = 0, label = "-/-") : Ysuser?
    y_uid = ysuser.origin_id
    ofile = "#{DIR}/#{y_uid}/#{page}.json"

    if FileUtil.fresh?(ofile, Time.utc - 2.days - 6.hours * page)
      return unless @reseed # skip seeding old data
    elsif !@http.save!(api_url(y_uid, page), ofile, label)
      return ysuser
    end

    lists, total = YslistRaw.from_list(File.read(ofile))

    stime = FileUtil.mtime_int(ofile)
    lists.each(&.seed!(stime, ysuser: ysuser))

    total = ysuser.list_total if ysuser.list_total > total
    count = Yslist.query.where(ysuser_id: ysuser.id).count.to_i

    ysuser.update(list_total: total, list_count: count)
    Log.info { "- yslists: #{Yslist.query.count}".colorize.cyan }
  end

  def api_url(y_uid : Int32, page = 1)
    "https://api.yousuu.com/api/user/#{y_uid}/booklistDetail?page=#{page}&t=#{Time.utc.to_unix_ms}"
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
