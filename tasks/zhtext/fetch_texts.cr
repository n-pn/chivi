# require "option_parser"
# require "../shared/bootstrap"

# class CV::FetchText
#   DIR = "var/chaps/texts/=base"

#   @queue = [] of ChInfo

#   def initialize(@nvinfo : Wninfo)
#     @snvid = @nvinfo.bhash

#     @nvinfo.nvseeds.each do |nvseed|
#       next if SnameMap.map_type(nvseed.sname) < 2
#       FileUtils.mkdir_p("var/chaps/.html/#{nvseed.sname}/#{nvseed.snvid}")
#     end

#     refresh_list!
#   end

#   def refresh_list!
#     if nvseed = Chroot.find(@nvinfo.id, 0)
#       nvseed.refresh!(force: Time.utc - 4.weeks > Time.unix(nvseed.atime))
#     else
#       Chroot.init!(@nvinfo, 0)
#     end
#   end

#   def make_queue!
#     files = Dir.glob("#{DIR}/#{@snvid}/*.tsv")

#     files.each do |file|
#       ChList.new(file).data.each_value do |chinfo|
#         @queue << chinfo if should_crawl?(chinfo)
#       end
#     end

#     @queue.uniq!(&.chidx)
#     @queue.size
#   end

#   private def should_crawl?(chinfo : ChInfo)
#     sname = chinfo.proxy.try(&.sname) || "=base"
#     return false if SnameMap.map_type(sname) < 2 || sname.in?("5200", "jx_la")

#     return true if chinfo.chidx <= 128
#     chinfo.chidx % (chinfo.chidx // 128 + 1) == 0
#   end

#   def crawl!(label = "1/1")
#     return if @queue.empty?

#     @queue.each_with_index(1) do |chinfo, idx|
#       chtext = ChText.new("=base", @snvid, chinfo)
#       next if chtext.exists?

#       chtext.fetch!(mkdir: false, lbl: "#{label} | #{idx}/#{@queue.size}")
#       update_chinfo!(chinfo)
#     ensure
#       sleep_by_sname(chinfo.proxy.try(&.sname) || "")
#     end
#   end

#   @cache = {} of String => ChList

#   def chlist(sname : String, snvid : String, pgidx : Int16)
#     label = "#{sname}/#{snvid}/#{pgidx}"
#     @cache[label] ||= ChList.new("#{ChRepo::DIR}/#{label}.tsv")
#   end

#   def pgidx(chidx : Int16)
#     (chidx - 1) // ChRepo::PSIZE
#   end

#   def update_chinfo!(chinfo : ChInfo)
#     pgidx = self.pgidx(chinfo.chidx)
#     self.chlist("=base", @snvid, pgidx).store!(chinfo)

#     return unless proxy = chinfo.proxy

#     chinfo = chinfo.dup.tap(&.proxy = nil)
#     self.chlist(proxy.sname, proxy.snvid, pgidx).store!(chinfo)
#   end

#   def sleep_by_sname(sname : String)
#     case sname
#     when "shubaow", "biqu5200"
#       sleep Random.rand(1000..2000).milliseconds
#     end
#   end

#   def self.run!(argv = ARGV)
#     workers = 8

#     OptionParser.parse(ARGV) do |opt|
#       opt.banner = "Usage: fetch_zhtexts [arguments]"
#       opt.on("-t WORKERS", "Parallel workers") { |x| workers = x.to_i }
#     end

#     channel = Channel(Nil).new(workers)

#     query = "select nvinfo_id from ubmemos where status > 0"
#     infos = Wninfo.query.where("id IN (#{query})").sort_by("weight").to_set
#     infos.concat Wninfo.query.sort_by("weight").limit(20000)

#     total = infos.size
#     infos.each_with_index(1) do |info, idx|
#       spawn do
#         task = new(info)
#         task.make_queue!
#         task.crawl!("#{idx}/#{total}")
#       ensure
#         channel.send(nil)
#       end

#       channel.receive if idx > workers
#     end

#     workers.times { channel.receive }
#   end
# end

# CV::FetchText.run!
