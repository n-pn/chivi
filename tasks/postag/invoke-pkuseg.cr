require "colorize"
require "compress/zip"
require "file_utils"
require "option_parser"

class CV::Postag
  INP_DIR = "_db/chseed"
  OUT_DIR = "_db/vpinit/pkuseg"

  def initialize(@sname : String, @snvid : String, @redo = false)
    @inp_dir = File.join(INP_DIR, @sname, @snvid)
    @out_dir = File.join(OUT_DIR, @sname, @snvid)
  end

  SCRIPT = "tasks/postag/pkuseg-runner.py"
  IOPIPE = Process::Redirect::Inherit

  def run!(mode = 1, wrks = 3)
    extract_txt(tag_mode: mode)
    Process.run("python3", [SCRIPT, @sname, @snvid], output: IOPIPE)
  end

  def extract_txt(tag_mode = 1) : Nil
    files = Dir.glob("#{@inp_dir}/*.zip")
    tag_mode = 2 if files.size < 3 # parse all if total chapters < 200

    FileUtils.mkdir_p(@out_dir)

    files.each do |zip_file|
      extract_zip(zip_file, tag_mode: tag_mode)
      tag_mode = 0 if tag_mode == 1 # reset tag_mode unless tagging all
    end
  end

  def extract_zip(zip_file : String, tag_mode = 0) : Nil
    Compress::Zip::File.open(zip_file) do |file|
      file.entries.each_with_index do |entry, index|
        next unless should_tag?(tag_mode, index)
        txt_file = File.join(@out_dir, entry.filename)

        tag_file = txt_file.sub(".txt", ".dat")
        next if !@redo && File.exists?(tag_file)

        entry.open { |io| File.write(txt_file, io.gets_to_end) }
      end
    end
  end

  # tag_mode:
  # - 0: only postag every 10th chaps
  # - 1: postag every 10th chaps plus first 50 chaps
  # - 2: postag all entries inside the archive
  private def should_tag?(tag_mode : Int32, chap_index : Int32)
    return true if tag_mode == 2
    return true if chap_index % 10 == 0
    tag_mode == 1 && chap_index < 50
  end

  class_getter library : Set(String) do
    inp_dir = "_db/vi_users/marks"
    bhashes = Dir.children(inp_dir).map { |x| File.basename(x, ".tsv") }
    Set(String).new(bhashes)
  end

  def self.should_tag?(bhash : String, favi = false)
    return true unless favi
    library.includes?(bhash)
  end
end

wrks, mode, redo, favi = 6, 1, false, false

OptionParser.parse(ARGV) do |opt|
  opt.banner = "Usage: invoke-pkuseg [arguments]"
  opt.on("-t THREADS", "Parallel workers") { |x| wrks = x.to_i }
  opt.on("-m MODE", "Less or more chaps") { |x| mode = x.to_i }
  opt.on("-r", "Redo postagging") { redo = true }
  opt.on("-f", "Only favorited books") { favi = true }
end

# wrks = files.size if wrks > files.size
wrks = 1 if wrks < 1
chan = Channel(Nil).new(wrks)

lines = File.read_lines("priv/zhseed.tsv").reject(&.empty?)

lines.each_with_index(1) do |line, idx|
  chan.receive if idx > wrks

  spawn do
    sname, snvid, bhash, bslug = line.split('\t')

    if CV::Postag.should_tag?(bhash, favi)
      puts "- <#{idx}/#{lines.size}> [#{sname}/#{snvid}] #{bslug}".colorize.yellow
      tagger = CV::Postag.new(sname, snvid, redo: redo)
      tagger.run!(mode: mode, wrks: wrks)
    else
      puts "- skipping: #{bslug}"
    end
  rescue err
    puts err.message.colorize.red
  ensure
    chan.send(nil)
  end
end

wrks.times { chan.receive }
