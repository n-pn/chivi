require "colorize"
require "compress/zip"
require "file_utils"
require "option_parser"
require "../shared/bootstrap"

class CV::Tagger
  INP_DIR = "var/chtexts"
  OUT_DIR = "_db/vpinit/baidulac"

  getter bname : String

  @max_size : Int32

  def initialize(@nvinfo : Nvinfo)
    @bname = nvinfo.bslug

    if nvseed = Zhbook.find(nvinfo.id, 0)
      force = (Time.utc - 10.days).to_unix > nvseed.atime
      nvseed.refresh!(force: force)
    else
      nvseed = Zhbook.init!(nvinfo, 0)
    end

    @max_size = nvseed.chap_count // 2
    @max_size = 400 if @max_size > 400

    @inp_dir = File.join(INP_DIR, "chivi", nvseed.snvid)
    @out_dir = File.join(OUT_DIR, @bname)

    FileUtils.mkdir_p(@out_dir)
  end

  def copy!(nvseeds : Array(Zhbook))
    nvseeds.sort_by!(&.zseed).each { |x| copy_old!(x) }
  end

  def copy_old!(nvseed : Zhbook)
    return if nvseed.zseed == 0

    old_dir = File.join(OUT_DIR, ".old", nvseed.sname, nvseed.snvid)
    return unless File.exists?(old_dir)

    inp_dir = File.join(INP_DIR, nvseed.sname, nvseed.snvid)
    indexes = {} of String => Int32

    Dir.glob("#{inp_dir}/*.tsv").each do |file|
      ChList.new(file).data.each_value do |info|
        indexes[info.schid] = info.chidx
      end
    end

    Dir.glob("#{old_dir}/*-0.tsv").each do |old_tsv|
      next unless chidx = indexes[get_chidx(old_tsv)]?

      out_tsv = File.join(@out_dir, "#{chidx}-0.tsv")
      next if File.exists?(out_tsv)

      FileUtils.mv(old_tsv, out_tsv)
      puts "- inherit old file #{old_tsv}".colorize.green
    end

    FileUtils.rm_rf(old_dir)
  end

  SCRIPT = "tasks/postag/baidu-lac.py"

  # IOPIPE = Process::Redirect::Inherit

  def get_chidx(file : String)
    File.basename(file, ".tsv").split("-", 2).first
  end

  def parse!(redo = false)
    existed = Dir.glob("#{@out_dir}/*.tsv")
    return if existed.size > @max_size

    existed = existed.map { |x| get_chidx(x).to_i }.to_set

    files = Dir.glob("#{@inp_dir}/*.tsv")
    files.each do |file|
      list = ChList.new(file)
      list.data.each_value do |info|
        next if !redo && existed.includes?(info.chidx)
        extract_text(info) if should_parse?(info.chidx)
      rescue err
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

  def extract_text(info : ChInfo)
    return unless proxy = info.proxy

    chidx = info.chidx
    schid = info.schid

    sname = proxy.sname
    snvid = proxy.snvid

    out_txt = "#{@out_dir}/#{chidx}-0.txt"
    return if File.exists?(out_txt)

    pgidx = (chidx - 1) // 128
    inp_zip = "#{INP_DIR}/#{sname}/#{snvid}/#{pgidx}.zip"
    return unless File.exists?(inp_zip)

    Compress::Zip::File.open(inp_zip) do |zip|
      return unless entry = zip["#{schid}-0.txt"]?
      puts "- #{out_txt} extracted".colorize.cyan
      File.write(out_txt, entry.open(&.gets_to_end))
    end
  end

  def self.run!(argv = ARGV)
    workers = 6
    bslug = ""
    redo = false

    OptionParser.parse(argv) do |opt|
      opt.banner = "Usage: baidu-lac-invoke [arguments]"
      opt.on("-t WORKERS", "Parallel workers") { |x| workers = x.to_i }
      opt.on("-r", "Redo postagging") { redo = true }
      opt.on("-b BSLUG", "Do a single book") { |x| bslug = x }
    end

    if bslug.empty?
      self.batch(workers, redo)
    else
      self.entry(bslug, redo)
    end
  end

  def self.batch(workers = 6, redo = false)
    workers = 1 if workers < 1
    channel = Channel(Nil).new(workers)

    query = "select nvinfo_id from ubmemos where status> 0"
    infos = Nvinfo.query.where("id IN (#{query})").sort_by("weight").to_set
    infos.concat Nvinfo.query.sort_by("weight").limit(20000)

    infos.each_with_index(1) do |info, idx|
      spawn do
        puts "- <#{idx}/#{infos.size}> #{info.bslug}".colorize.yellow
        new(info).parse!(redo: redo)
      rescue err
        puts err.inspect_with_backtrace
      ensure
        channel.send(nil)
      end

      channel.receive if idx > workers
    end

    workers.times { channel.receive }
  end

  def self.entry(bslug : String, redo = false)
    return unless nvinfo = Nvinfo.find({bslug: bslug})
    puts "#{nvinfo.bslug}: #{nvinfo.vname}".colorize.red
    new(nvinfo).parse!(redo: redo)
  end
end

CV::Tagger.run!
