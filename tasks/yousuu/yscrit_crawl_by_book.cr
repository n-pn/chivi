# require "../shared/http_client"
# require "../shared/yscrit_raw"

# class CV::YscritCrawlByBook
#   DIR = "_db/yousuu/crits"
#   Dir.mkdir_p(DIR)

#   enum CrMode
#     Head; Tail; Rand
#   end

#   @http = HttpClient.new(ARGV.includes?("--refresh-proxy"))
#   @data : Array(Ysbook)

#   def initialize(crmode : CrMode = :tail, @reseed = false)
#     @data = Ysbook.query.where("crit_count < crit_total").to_a

#     case crmode
#     when .rand? then @data.shuffle!
#     when .tail? then @data.sort_by!(&.id.-)
#     when .head? then @data.sort_by!(&.id)
#     end
#   end

#   def crawl!(page = 1)
#     queue = @data.select!(&.crit_total.>= (page &- 1) &* 20)
#     exit 0 if queue.empty?

#     loops = 0

#     until queue.empty?
#       qsize = queue.size
#       qnext = [] of Ysbook

#       Log.info { "<#{page}> [loop: #{loops}, size: #{qsize}]".colorize.cyan }

#       workers = qsize
#       workers = 10 if workers > 10
#       channel = Channel(Ysbook?).new(workers)

#       queue.each_with_index(1) do |ysbook, idx|
#         spawn do
#           label = "[#{page}] <#{idx}/#{qsize}> #{ysbook.id}"
#           channel.send(do_crawl!(ysbook, page, label: label))
#         end

#         channel.receive.try { |s| qnext << s } if idx > workers
#       end

#       workers.times do
#         channel.receive.try { |s| qnext << s }
#       end

#       exit 0 if @http.no_proxy?
#       queue = qnext
#       loops += 1
#     end
#   end

#   def do_crawl!(ysbook : Ysbook, page = 1, label = "-/-") : Ysbook?
#     y_bid = ysbook.id
#     ofile = "#{DIR}/#{y_bid // 1000}/#{y_bid}-#{page}.json"

#     if FileUtil.fresh?(ofile, Time.utc - 3.days - 6.hours * page)
#       return unless @reseed # skip seeding old data
#     elsif !@http.save!(api_url(y_bid, page), ofile, label)
#       return ysbook
#     end

#     crits, total = YscritRaw.from_book(File.read(ofile))

#     stime = FileUtil.mtime_int(ofile)
#     crits.each(&.seed!(stime: stime))

#     total = ysbook.crit_total if ysbook.crit_total > total
#     count = YS::Yscrit.query.where(ysbook_id: ysbook.id).count.to_i

#     ysbook.update(crit_total: total, crit_count: count)
#     Log.info { "- yscrits: #{YS::Yscrit.query.count}".colorize.cyan }
#   rescue err
#     Log.error { err }
#   end

#   private def api_url(y_bid : Int64, page : Int32 = 1)
#     "https://api.yousuu.com/api/book/#{y_bid}/comment?type=latest&page=#{page}"
#   end

#   ###############

#   def self.run!(argv = ARGV)
#     crmode = CrMode::Rand
#     reseed = false

#     OptionParser.parse(argv) do |opt|
#       opt.on("-m MODE", "Crawl mode") { |x| crmode = CrMode.parse(x) }
#       opt.on("-r", "Reseed content") { reseed = true }
#     end

#     worker = new(crmode, reseed)
#     1.upto(100) { |page| worker.crawl!(page) }
#   end

#   run!(ARGV)
# end
