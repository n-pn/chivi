# require "option_parser"
# require "../shared/bootstrap"

# class CV::CrawlText
#   INP_DIR = "var/chaps/.html"

#   DIR = "var/chaps/texts"

#   def initialize(@sname : String, @snvid : String)
#     File.mkdir_p("#{INP_DIR}/#{sname}/#{snvid}")

#     @out_dir = File.join("#{DIR}/#{sname}/#{snvid}")
#   end

#   # modes:
#   # 0 => fast mode: only download neccessary for postag analyze
#   # 1 => fetch all: download all missing texts
#   # 2 => redownload all

#   def make_queue!(mode = 0)
#     # create cache folder

#     avail = list_avail
#     queue = [] of ChInfo

#     Dir.glob("#{@out_dir}/*.tsv").each do |tsv_file|
#       # create text folder
#       File.mkdir_p(tsv_file.sub(".tsv", ""))

#       ChList.new(tsv_file).data.each_value do |info|
#         next if mode < 2 && avail.includes?(info.schid)
#         queue << info if should_crawl?(info, mode)
#       end
#     end

#     queue
#   end

#   def list_avail
#     avail = Set(String).new

#     Dir.glob("#{@out_dir}/*.zip").each do |zip_file|
#       Compress::Zip::Reader.open(zip_file) do |zip|
#         zip.each_entry do |entry|
#           avail << File.basename(entry.filename, ".txt").split("-").first
#         end
#       end
#     rescue err
#       File.delete(zip_file)
#     end

#     avail
#   end

#   private def should_crawl?(chinfo : ChInfo, mode = 0)
#     return true if chinfo.chidx <= 128 || mode == 1
#     chinfo.chidx % (chinfo.chidx // 128 + 1) == 0
#   end

#   def crawl!(queue : Array(ChInfo), workers = 8)
#     return if queue.empty?

#     workers = queue.size if workers > queue.size
#     channel = Channel(Nil).new(workers)

#     queue.each_with_index(1) do |chinfo, idx|
#       spawn do
#         thrott! if fetch!(chinfo, "#{idx}/#{queue.size}")
#       ensure
#         channel.send(nil)
#       end

#       channel.receive if idx > workers
#     end

#     workers.times { channel.receive }
#   end

#   TTL = 20.years

#   # return false if chap existed or html cached
#   def fetch!(chinfo : ChInfo, lbl = "1/1") : Bool
#     chtext = ChText.new(@sname, @snvid, chinfo)

#     remote = RemoteText.new(@sname, @snvid, chinfo.schid, ttl: TTL, lbl: lbl)
#     cached = File.exists?(remote.file)

#     lines = remote.paras.tap { |x| x.unshift(remote.title) unless remote.title.empty? }
#     chtext.save!(lines, zipping: false, mkdir: false)

#     !cached
#   rescue err
#     puts err.inspect_with_backtrace
#     false
#   end

#   def thrott!
#     case @sname
#     when "shubaow", "biqu5200"
#       sleep Random.rand(1000..2000).milliseconds
#     else
#       sleep Random.rand(50..100).milliseconds
#     end
#   end

#   def cleanup!
#     Dir.glob("#{@out_dir}/*/").each do |text_dir|
#       zip_path = text_dir.sub(/\/$/, ".zip")
#       `zip --include=\\*.txt -rjmq #{zip_path} #{text_dir}`
#       `rmdir "#{text_dir}"`
#     rescue err
#       puts err
#     end

#     `rm -f #{@out_dir}/*.txt` # delete old texts
#   end

#   ######################

#   def self.map_workers(sname : String)
#     case sname
#     when "zhwenpg", "shubaow"  then 1
#     when "paoshu8", "biqu5200" then 2
#     when "duokan8", "69shu"    then 4
#     else                            6
#     end
#   end

#   def self.load_snvids(sname : String) : Array(String)
#     Dir.children("var/chaps/texts/#{sname}")
#   end

#   def self.run!(argv = ARGV)
#     workers = 0
#     sname = "hetushu"

#     snvids = [] of String
#     mode = 0

#     OptionParser.parse(ARGV) do |opt|
#       opt.banner = "Usage: crawl_texts [arguments]"
#       opt.on("-t WORKERS", "Parallel workers") { |x| workers = x.to_i }
#       opt.on("-s SNAME", "Seed name") { |s| sname = s }
#       opt.on("-n SNVID", "Remote ID") { |n| snvids = n.split("|") }
#       opt.on("-m MODE", "Crawl mode") { |m| mode = m.to_i }
#     end

#     workers = map_workers(sname) if workers < 1

#     snvids = load_snvids(sname) if snvids.empty?
#     puts "TOTAL BOOKS: #{snvids.size}".colorize.yellow

#     snvids.each_with_index(1) do |snvid, idx|
#       crawler = new(sname, snvid)
#       queue = crawler.make_queue!(mode: mode)

#       puts "<#{idx}/#{snvids.size}> #{snvid} #{queue.size} chaps missing".colorize.yellow

#       crawler.crawl!(queue, workers)
#       crawler.cleanup!
#     end
#   end

#   run!(ARGV)
# end
