require "colorize"
require "compress/zip"
require "file_utils"
require "option_parser"
require "../shared/bootstrap"

class CV::BdLacInvoke
  INP_DIR = "var/chtexts"
  OUT_DIR = "_db/vpinit/bd_lac/raw"

  getter chap_count = 0

  def initialize(@nvinfo : Nvinfo, @parse_all = false)
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

  # IOPIPE = Process::Redirect::Inherit

  def parse!(lbl = "1/1") : Nil
    return if @chap_count == 0
    existed = Dir.glob("#{@out_path}/*.tsv")

    if @@skip_if_plenty && existed.size >= calc_max_size(@chap_count)
      color = :green
    else
      color = :yellow
      extract(existed.map { |x| get_chidx(x) }.to_set)
    end

    Log.info { "<#{lbl}> #{@nvinfo.bslug}: #{existed.size} parsed".colorize(color) }
    Process.run("python3", {SCRIPT, @dir_name})
  end

  def get_chidx(file : String)
    File.basename(x, ".tsv").split("-", 2).first
  end

  def extract(existed : Set(String))
    Dir.glob("#{@inp_dir}/*.tsv").each do |list_file|
      chlist = ChList.new(list_file)

      chlist.data.each_value do |chinfo|
        next if existed.includes?(chinfo.chidx)
        extract_text(chinfo) if @parse_all || should_parse?(chinfo.chidx)
      rescue err
        Log.error { err.inspect_with_backtrace }
      end
    end
  end

  def calc_max_size(chap_count : Int32)
    return 384 if chap_count > 768
    return 256 if chap_count < 512
    chap_count // 2
  end

  def should_parse?(chidx : Int32)
    return true if chidx <= 128
    chidx % (chidx // 128 &+ 1) == 0
  end

  def extract_text(info : ChInfo) : Nil
    return unless proxy = info.proxy

    out_txt = "#{@out_path}/#{info.chidx}-0.txt"
    return if File.exists?(out_txt)

    pgidx = (info.chidx &- 1) // 128
    inp_zip = "#{INP_DIR}/#{proxy.sname}/#{proxy.snvid}/#{pgidx}.zip"

    return unless File.exists?(inp_zip)

    Compress::Zip::File.open(inp_zip) do |zip|
      return unless entry = zip["#{info.schid}-0.txt"]?
      File.write(out_txt, entry.open(&.gets_to_end))
    rescue err
      Log.error { err.colorize.red }
    end
  end

  ####################

  class_property skip_if_plenty = false

  def self.run!(argv = ARGV)
    workers = 6
    books = [] of String

    OptionParser.parse(argv) do |opt|
      opt.banner = "Usage: bd_lac-invoke [arguments]"
      opt.on("-t WORKERS", "Parallel workers") { |x| workers = x.to_i }
      opt.on("--skip-if-plenty", "Skip if enough chapters parsed") { @@skip_if_plenty = true }

      opt.unknown_args { |args| books = args }
    end

    if books.empty?
      query = "select nvinfo_id from ubmemos where status > 0"
      infos = Nvinfo.query.where("id IN (#{query})").sort_by("weight").to_set
      infos.concat Nvinfo.query.sort_by("weight").limit(20000)
    else
      infos = Nvinfo.query.where("bhash in ?", books).to_set
    end

    workers = infos.size if workers > infos.size
    channel = Channel(Nil).new(workers)

    infos.each_with_index(1) do |info, idx|
      spawn do
        new(info, parse_all: idx < 1000).parse!(lbl: "#{idx}/#{infos.size}")
      rescue err
        Log.error { err.inspect_with_backtrace }
      ensure
        channel.send(nil)
      end

      channel.receive if idx > workers
    end

    workers.times { channel.receive }
  end

  run!(ARGV)
end
