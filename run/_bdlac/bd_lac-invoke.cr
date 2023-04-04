# require "colorize"
# require "compress/zip"
# require "option_parser"
# require "../shared/bootstrap"

# class CV::BdLacInvoke
#   INP_DIR = "var/chaps/texts"
#   OUT_DIR = "var/inits/bdtmp/raw"

#   getter chap_count = 0
#   getter to_parse = 0

#   @dir_name : String

#   def initialize(@nvinfo : Nvinfo, @parse_all = false)
#     @inp_dir = File.join(INP_DIR, "=base", @nvinfo.id)

#     @dir_name = nvinfo.bslug

#     @out_path = File.join(OUT_DIR, @dir_name)
#     Dir.mkdir_p(@out_path)

#     @chap_count = load_chap_count(@nvinfo)
#   end

#   def load_chap_count(nvinfo : Nvinfo)
#     return 0 if nvinfo.subdue_id > 0

#     if nvseed = Chroot.find(nvinfo.id, 0)
#       nvseed.refresh!(force: false)
#     else
#       nvseed = Chroot.init!(nvinfo, 0)
#     end

#     nvseed.chap_count
#   end

#   SCRIPT = "tasks/postag/baidu-lac.py"

#   # IOPIPE = Process::Redirect::Inherit

#   def parse!(lbl = "1/1") : Nil
#     return if @chap_count == 0
#     existed = Dir.glob("#{@out_path}/*.tsv")

#     if @@skip_if_plenty && existed.size >= calc_max_size(@chap_count)
#       color = :green
#     else
#       color = :yellow
#       extract(existed.map { |x| get_chidx(x) }.to_set)
#     end

#     Log.info { "<#{lbl}> #{@nvinfo.bslug.colorize(color)}: #{existed.size.colorize(color)} parsed, \
#                 to parse: #{@to_parse.colorize(color)}" }
#     Process.run("python3", {SCRIPT, @dir_name})
#   end

#   def get_chidx(file : String)
#     File.basename(file, ".tsv").split("-", 2).first
#   end

#   def extract(existed : Set(String))
#     Dir.glob("#{@inp_dir}/*.tsv").each do |list_file|
#       chlist = ChList.new(list_file)

#       chlist.data.each_value do |chinfo|
#         next if existed.includes?(chinfo.chidx)
#         extract_text(chinfo) if @parse_all || should_parse?(chinfo.chidx)
#       rescue err
#         Log.error { err.inspect_with_backtrace }
#       end
#     end
#   end

#   def calc_max_size(chap_count : Int16)
#     return chap_count if chap_count < 256
#     return 384 if chap_count > 768
#     chap_count < 512 ? 256 : chap_count // 2
#   end

#   def should_parse?(chidx : Int16)
#     return true if chidx <= 128
#     chidx % (chidx // 128 &+ 1) == 0
#   end

#   def extract_text(info : ChInfo) : Nil
#     return unless proxy = info.proxy

#     out_txt = "#{@out_path}/#{info.chidx}-0.txt"
#     return if File.exists?(out_txt) || File.exists?(out_txt.sub(".txt", ".tsv"))

#     pgidx = (info.chidx &- 1) // 128
#     inp_zip = "#{INP_DIR}/#{proxy.sname}/#{proxy.snvid}/#{pgidx}.zip"

#     return unless File.exists?(inp_zip)

#     Compress::Zip::File.open(inp_zip) do |zip|
#       return unless entry = zip["#{info.schid}-0.txt"]?
#       File.write(out_txt, entry.open(&.gets_to_end))
#       @to_parse += 1
#     rescue err
#       Log.error { err.colorize.red }
#     end
#   end

#   ####################

#   class_property skip_if_plenty = false

#   def self.run!(argv = ARGV)
#     workers = 6
#     books = [] of String

#     OptionParser.parse(argv) do |opt|
#       opt.banner = "Usage: bd_lac-invoke [arguments]"
#       opt.on("-t WORKERS", "Parallel workers") { |x| workers = x.to_i }
#       opt.on("--skip-if-plenty", "Skip if enough chapters parsed") { @@skip_if_plenty = true }

#       opt.unknown_args { |args| books = args }
#     end

#     if books.empty?
#       query = "select nvinfo_id from ubmemos where status > 0"
#       infos = Nvinfo.query.where("id IN (#{query})").sort_by("weight").to_set
#       infos.concat Nvinfo.query.sort_by("weight").limit(20000)
#     else
#       infos = Nvinfo.query.where { bslug.in?(books) }.to_set
#     end

#     workers = infos.size if workers > infos.size
#     channel = Channel(Nil).new(workers)

#     infos.each_with_index(1) do |info, idx|
#       channel.receive if idx > workers

#       spawn do
#         new(info).parse!(lbl: "#{idx}/#{infos.size}")
#       rescue err
#         Log.error { err.inspect_with_backtrace }
#       ensure
#         channel.send(nil)
#       end
#     end

#     workers.times { channel.receive }
#   end

#   run!(ARGV)
# end
