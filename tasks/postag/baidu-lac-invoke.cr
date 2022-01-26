require "colorize"
require "compress/zip"
require "file_utils"
require "option_parser"
require "../shared/bootstrap"

class CV::Tagger
  INP_DIR = "var/chtexts"
  OUT_DIR = "_db/vpinit/baidulac"

  def initialize(@bhash : String, @redo = false)
    @inp_dir = File.join(INP_DIR, "chivi", @bhash)
    @out_dir = File.join(OUT_DIR, "chivi", @bhash)
    FileUtils.mkdir_p(@out_dir)
  end

  SCRIPT = "tasks/postag/baidu-lac.py"

  # IOPIPE = Process::Redirect::Inherit

  def run!(load_all = false)
    files = Dir.glob("#{@inp_dir}/*.tsv")
    load_all ||= files.size < 3

    files.each do |file|
      list = ChList.new(file)
      list.data.each_value do |info|
        next if info.chars == 0
        next unless load_all || info.chidx < 64 || info.chidx % 8 == 0

        out_file = "#{@out_dir}/#{info.chidx}-0.txt"
        tsv_file = "#{@out_dir}/#{info.chidx}-0.tsv"
        next if !@redo && File.exists?(out_file) || File.exists?(tsv_file)

        pgidx = (info.o_chidx - 1) // 128
        zip_file = "#{INP_DIR}/#{info.o_sname}/#{info.o_snvid}/#{pgidx}.zip"

        `unzip -p #{zip_file} #{info.schid}-0.txt > #{out_file}`
      rescue err
        puts info
        puts err.inspect_with_backtrace
        exit(1)
      end
    end

    Process.run("python3", [SCRIPT, "chivi", @bhash])
  end

  def self.run!(argv = ARGV)
    workers, load_all, redo = 6, false, false

    OptionParser.parse(argv) do |opt|
      opt.banner = "Usage: invoke-pkuseg [arguments]"
      opt.on("-t THREADS", "Parallel workers") { |x| workers = x.to_i }
      opt.on("-a", "Less or more chaps") { load_all = true }
      opt.on("-r", "Redo postagging") { redo = true }
    end

    # workers = files.size if workers > files.size
    workers = 1 if workers < 1
    channel = Channel(Nil).new(workers)

    infos = Nvinfo.query.sort_by("weight").limit(30000)
    infos.to_a.each_with_index(1) do |info, idx|
      channel.receive if idx > workers

      spawn do
        puts "- <#{idx}> #{info.bslug}".colorize.yellow
        new(info.bhash, redo: redo).run!(load_all: load_all)
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
