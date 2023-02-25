# require "json"
# require "option_parser"

# require "../shared/bootstrap"
# require "../shared/http_client"
# require "../shared/YS::Yslist_raw"

# class CV::YslistCrawl
#   DIR = "_db/yousuu/lists-by-page"
#   Dir.mkdir_p(DIR)

#   @http = HttpClient.new(false)

#   def initialize(@type = "man", @screen = "comprehensive", @reseed = false)
#   end

#   enum CrMode
#     Head; Tail; Rand
#   end

#   def crawl!(pages = 20, mode : CrMode = :head)
#     queue = (1..pages).to_a

#     case mode
#     when .tail? then queue.reverse!
#     when .rand? then queue.shuffle!
#     end

#     loops = 0

#     until queue.empty?
#       qsize = queue.size

#       puts "\n[loop: #{loops}, mode: #{mode}, size: #{qsize}]".colorize.cyan

#       qnext = [] of Int32

#       workers = queue.size
#       workers = 10 if workers > 10
#       channel = Channel(Int32?).new(workers)

#       queue.each_with_index(1) do |snvid, idx|
#         spawn do
#           label = "<#{idx}/#{qsize}> [#{snvid}]"
#           channel.send(do_crawl!(snvid, label: label))
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

#   def do_crawl!(page : Int32, label : String)
#     ofile = "#{DIR}/#{@type}-#{@screen}/#{page}.json"

#     if FileUtil.fresh?(ofile, Time.utc - 1.days)
#       return unless @reseed
#     elsif !@http.save!(api_url(page), file, label)
#       return page
#     end

#     lists, _ = YS::YslistRaw.from_list(File.read(file))

#     stime = FileUtil.mtime_int(file)
#     lists.each(&.seed!(stime))

#     Log.info { "yslists: #{YS::Yslist.query.count}".colorize.cyan }
#   end

#   private def api_url(page = 1)
#     "https://api.yousuu.com/api/booklists?type=#{@type}&screen=#{@screen}&page=#{page}&t=#{Time.utc.to_unix_ms}"
#   end

#   ################

#   def self.run!(argv = ARGV)
#     crmode = CrMode::Tail

#     type = "man"
#     screen = "comprehensive"
#     page_limit = 732

#     OptionParser.parse(ARGV) do |opt|
#       opt.on("-m MODE", "Crawl mode") { |x| crmode = Mode.parse(x) }
#       opt.on("-u LIMIT", "Page limit") { |x| page_limit = x.to_i }
#       opt.on("-t TYPE", "List type") { |x| type = x }
#       opt.on("-s SCREEN", "List screen") { |x| screen = x }
#     end

#     worker = new(type, screen)
#     worker.crawl!(page_limit, crawl_mode)
#   end

#   run!(ARGV)
# end
