# require "../shared/http_client"
# require "../shared/ysrepl_raw"

# class CV::YsreplCrawl
#   DIR = "_db/yousuu/repls"
#   Dir.mkdir_p(DIR)

#   enum CrMode
#     Head; Tail; Rand
#   end

#   @http = HttpClient.new(false)
#   @data : Array(YS::Yscrit)

#   def initialize(crmode : CrMode, @reseed = false)
#     @data = YS::Yscrit.query.where("repl_count < repl_total").to_a

#     case crmode
#     when .rand? then @data.shuffle!
#     when .tail? then @data.sort_by!(&.id.-)
#     when .head? then @data.sort_by!(&.id)
#     end
#   end

#   def crawl!(page = 1)
#     queue = @data.select!(&.repl_total.>= (page &- 1) &* 20)
#     exit 0 if queue.empty?

#     loops = 0

#     until queue.empty?
#       qsize = queue.size
#       qnext = [] of YS::Yscrit

#       Log.info { "<#{page}> [loop: #{loops}, size: #{qsize}]".colorize.cyan }

#       workers = qsize
#       workers = 10 if workers > 10
#       channel = Channel(YS::Yscrit?).new(workers)

#       queue.each_with_index(1) do |yscrit, idx|
#         spawn do
#           label = "[#{page}] <#{idx}/#{qsize}> [#{yscrit.id}]"
#           channel.send(do_crawl!(yscrit, page, label: label))
#         end

#         channel.receive.try { |x| qnext << x } if idx > workers
#       end

#       workers.times do
#         channel.receive.try { |x| qnext << x }
#       end

#       exit 0 if @http.no_proxy?
#       queue = qnext
#       loops += 1
#     end
#   end

#   def do_crawl!(yscrit : YS::Yscrit, page = 1, label = "-/-") : YS::Yscrit?
#     y_cid = yscrit.origin_id
#     ofile = "#{DIR}/#{y_cid[0..3]}/#{y_cid}-#{page}.json"

#     revp = (yscrit.repl_count &- 1) // 20 &+ 1 &- page

#     if FileUtil.fresh?(ofile, Time.utc - 2.days * revp - 4.days)
#       return unless @reseed # skip seeding old data
#     elsif !@http.save!(api_url(y_cid, page), ofile, label)
#       return yscrit
#     end

#     crits, total = YsreplRaw.from_list(File.read(ofile))

#     stime = FileUtil.mtime_int(ofile)
#     crits.each(&.seed!(stime: stime))

#     total = yscrit.repl_total if yscrit.repl_total > total
#     count = YS::Ysrepl.query.where(yscrit_id: yscrit.id).count.to_i

#     yscrit.update(repl_total: total, repl_count: count)
#     Log.info { "ysrepls: #{YS::Ysrepl.query.count}".colorize.cyan }
#   rescue err
#     puts err
#   end

#   private def api_url(y_cid : String, page = 1)
#     "https://api.yousuu.com/api/comment/#{y_cid}/reply?&page=#{page}"
#   end

#   #####################

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
