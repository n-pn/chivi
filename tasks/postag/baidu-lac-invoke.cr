require "colorize"
require "compress/zip"
require "file_utils"
require "option_parser"
require "../shared/bootstrap"

class CV::Tagger
  INP_DIR = "var/chtexts"
  OUT_DIR = "_db/vpinit/baidulac"

  getter bname : String

  def initialize(nvinfo : Nvinfo)
    @bname = nvinfo.bslug

    if nvseed = Zhbook.find(nvinfo.id, 0)
      nvseed.refresh!(force: true)
    else
      nvseed = Zhbook.init!(nvinfo, 0)
    end

    @inp_dir = File.join(INP_DIR, "chivi", nvseed.snvid)
    @out_dir = File.join(OUT_DIR, @bname)

    FileUtils.mkdir_p(@out_dir)
  end

  SCRIPT = "tasks/postag/baidu-lac.py"

  # IOPIPE = Process::Redirect::Inherit

  def run!(redo = false)
    files = Dir.glob("#{@inp_dir}/*.tsv")

    files.each do |file|
      list = ChList.new(file)
      list.data.each_value do |info|
        extract_text(info, redo: redo) if should_parse?(info.chidx)
      rescue err
        puts info
        puts err.inspect_with_backtrace
        exit(1)
      end
    end

    Process.run("python3", [SCRIPT, @bname])
  end

  def should_parse?(chidx : Int32)
    return true if chidx <= 128
    chidx % (chidx // 128 + 1) == 0
  end

  def extract_text(info : ChInfo, redo = false)
    return unless proxy = info.proxy

    chidx = info.chidx
    schid = info.schid

    sname = proxy.sname
    snvid = proxy.snvid

    out_txt = "#{@out_dir}/#{chidx}-0.txt"
    out_tsv = out_txt.sub(".txt", ".tsv")
    return if !redo && File.exists?(out_txt) || File.exists?(out_tsv)

    old_tsv = File.join(OUT_DIR, ".old", sname, snvid, "#{schid}-0.tsv")
    if File.exists?(old_tsv)
      puts "- inherit old file #{old_tsv}".colorize.green
      return FileUtils.mv(old_tsv, out_tsv)
    end

    pgidx = (chidx - 1) // 128
    inp_zip = "#{INP_DIR}/#{sname}/#{snvid}/#{pgidx}.zip"
    return unless File.exists?(inp_zip)

    Compress::Zip::File.open(inp_zip) do |zip|
      return unless entry = zip["#{schid}-0.txt"]?
      File.write(out_txt, entry.open(&.gets_to_end))
    end
  end

  def self.run!(argv = ARGV)
    workers, redo = 6, false

    OptionParser.parse(argv) do |opt|
      opt.banner = "Usage: baidu-lac-invoke [arguments]"
      opt.on("-t WORKERS", "Parallel workers") { |x| workers = x.to_i }
      opt.on("-r", "Redo postagging") { redo = true }
    end

    # workers = files.size if workers > files.size
    workers = 1 if workers < 1
    channel = Channel(Nil).new(workers)

    infos = Nvinfo.query.sort_by("weight").limit(10000).to_set

    query = "select nvinfo_id from ubmemos where status> 0"
    extra = Nvinfo.query.where("id IN (#{query})")

    infos.concat(extra.to_a)
    infos.each_with_index(1) do |info, idx|
      channel.receive if idx > workers

      spawn do
        puts "- <#{idx}/#{infos.size}> #{info.bslug}".colorize.yellow
        new(info).run!(redo: redo)
      rescue err
        puts err.message.colorize.red
      ensure
        channel.send(nil)
      end
    end

    workers.times { channel.receive }
  end
end

CV::Tagger.run!
