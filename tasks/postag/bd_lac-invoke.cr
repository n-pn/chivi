require "colorize"
require "compress/zip"
require "file_utils"
require "option_parser"
require "../shared/bootstrap"

class CV::BdLacInvoke
  INP_DIR = "var/chtexts"
  OUT_DIR = "_db/vpinit/bd_lac/raw"

  getter chap_count = 0

  def initialize(@nvinfo : Nvinfo)
    @inp_dir = File.join(INP_DIR, "chivi", @nvinfo.bhash)

    @dir_name = nvinfo.bslug

    @out_path = File.join(OUT_DIR, @dir_name)
    Dir.mkdir_p(@out_path)

    @chap_count = load_chap_count(@nvinfo)
  end

  def load_chap_count(nvinfo : Nvinfo)
    return 0 if nvinfo.subdue_id > 0

    if nvseed = Nvseed.find(nvinfo.id, 0)
      nvseed.refresh!(force: false)
    else
      nvseed = Nvseed.init!(nvinfo, 0)
    end

    nvseed.chap_count
  end

  SCRIPT = "tasks/postag/baidu-lac.py"

  SKIP_IF_ENOUGH = ARGV.includes?("--skip-enough")

  # IOPIPE = Process::Redirect::Inherit

  def parse!(redo = false, lbl = "1/1") : Nil
    return if @chap_count == 0
    existed = Dir.glob("#{@out_path}/*.tsv")

    if SKIP_IF_ENOUGH && existed.size > calc_max_size(@chap_count)
      Log.info { "<#{lbl}> #{@nvinfo.bslug}: #{existed.size} parsed".colorize.green }
      return
    else
      Log.info { "<#{lbl}> #{@nvinfo.bslug}: #{existed.size} parsed".colorize.yellow }
    end

    existed = existed.map { |x| File.basename(x, ".tsv").split("-", 2).first }.to_set

    Dir.glob("#{@inp_dir}/*.tsv").each do |list_file|
      chlist = ChList.new(list_file)

      chlist.data.each_value do |chinfo|
        next if !redo && existed.includes?(chinfo.chidx)
        extract_text(chinfo) if should_parse?(chinfo.chidx)
      rescue err
        Log.error { err.inspect_with_backtrace }
      end
    end

    Process.run("python3", {SCRIPT, @dir_name})
  end

  def calc_max_size(chap_count : Int32)
    return 384 if chap_count > 768
    return 256 if chap_count < 512
    chap_count // 2
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

    out_txt = "#{@out_path}/#{chidx}-0.txt"
    return if File.exists?(out_txt)

    inp_zip = "#{INP_DIR}/#{sname}/#{snvid}/#{(chidx &- 1) // 128}.zip"
    return unless File.exists?(inp_zip)

    Compress::Zip::File.open(inp_zip) do |zip|
      return unless entry = zip["#{schid}-0.txt"]?
      # puts "- #{sname}/#{snvid}/#{chidx}-0.txt extracted".colorize.cyan
      File.write(out_txt, entry.open(&.gets_to_end))
    rescue err
      Log.error { err.colorize.red }
    end
  end

  ####################

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

    query = "select nvinfo_id from ubmemos where status > 0"
    infos = Nvinfo.query.where("id IN (#{query})").sort_by("weight").to_set
    infos.concat Nvinfo.query.sort_by("weight").limit(20000)

    infos.each_with_index(1) do |info, idx|
      spawn do
        new(info).parse!(redo: redo, lbl: "#{idx}/#{infos.size}")
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

  run!
end
