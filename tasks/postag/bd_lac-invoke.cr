require "colorize"
require "compress/zip"
require "file_utils"
require "option_parser"
require "../shared/bootstrap"

class CV::BdLacInvoke
  INP_DIR = "var/chtexts"
  OUT_DIR = "_db/vpinit/bd_lac"

  getter chap_count = 0
  @dir_name : String

  def initialize(@nvinfo : Nvinfo)
    @inp_dir = File.join(INP_DIR, "chivi", @nvinfo.bhash)

    @dir_name = gen_dir_name(nvinfo)
    @out_path = File.join(OUT_DIR, @dir_name)

    @chap_count = load_chap_count(@nvinfo)
  end

  def gen_dir_name(nvinfo : Nvinfo)
    suffix = nvinfo.bhash[0..3]
    nvinfo.bslug.sub(/#{suffix}$/, nvinfo.bhash)
  end

  def load_chap_count(nvinfo : Nvinfo)
    if nvseed = Zhbook.find(nvinfo.id, 0)
      force = (Time.utc - 10.days).to_unix > nvseed.atime
      nvseed.refresh!(force: force)
    else
      nvseed = Zhbook.init!(nvinfo, 0)
    end

    nvseed.chap_count
  end

  SCRIPT = "tasks/postag/baidu-lac.py"

  # IOPIPE = Process::Redirect::Inherit

  def parse!(redo = false, lbl = "1/1") : Nil
    existed = glob_parsed_chaps
    puts "\n<#{lbl}> #{@nvinfo.bslug}: #{existed.size} parsed".colorize.yellow

    # max_size = calc_max_size(@chap_count)
    # if existed.size > max_size
    #   return puts "  surpass limit: #{max_size}, skipping".colorize.green
    # end

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

    Process.run("python3", [SCRIPT, @dir_name])
  end

  def get_chidx(file : String)
    File.basename(file, ".tsv").split("-", 2).first
  end

  def glob_parsed_chaps
    return Dir.glob("#{@out_path}/*.tsv") if File.exists?(@out_path)
    FileUtils.mkdir_p(@out_path)
    [] of String
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

    pgidx = (chidx - 1) // 128
    inp_zip = "#{INP_DIR}/#{sname}/#{snvid}/#{pgidx}.zip"
    return unless File.exists?(inp_zip)

    Compress::Zip::File.open(inp_zip) do |zip|
      return unless entry = zip["#{schid}-0.txt"]?
      puts "- #{sname}/#{snvid}/#{chidx} extracted".colorize.cyan
      File.write(out_txt, entry.open(&.gets_to_end))
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

    query = "select nvinfo_id from ubmemos where status> 0"
    infos = Nvinfo.query.where("id IN (#{query})").sort_by("weight").to_set
    infos.concat Nvinfo.query.sort_by("weight").limit(20000)

    infos.each_with_index(1) do |info, idx|
      spawn do
        next if info.subdue_id > 0

        parser = new(info)
        next if parser.chap_count == 0

        parser.parse!(redo: redo, lbl: "#{idx}/#{infos.size}")
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

CV::BdLacInvoke.run!
