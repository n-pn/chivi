require "colorize"
require "compress/zip"
require "file_utils"
require "option_parser"

class CV::Tagger
  INP_DIR = "var/chtexts"
  OUT_DIR = "_db/vpinit/baidulac"

  def initialize(@sname : String, @snvid : String, @redo = false)
    @inp_dir = File.join(INP_DIR, @sname, @snvid)
    @out_dir = File.join(OUT_DIR, @sname, @snvid)
  end

  SCRIPT = "tasks/postag/baidu-lac.py"
  IOPIPE = Process::Redirect::Inherit

  def run!(mode = 1)
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
        next if !@redo && File.exists?(txt_file.sub(".txt", ".tsv"))

        entry.open { |io| File.write(txt_file, io.gets_to_end) }
      end
    end
  end

  # tag_mode:
  # - 0: only postag every 8th chaps
  # - 1: postag every 8th chaps plus first 64 chaps
  # - 2: postag all entries inside the archive
  private def should_tag?(tag_mode : Int32, chap_index : Int32)
    return true if chap_index % 8 == 0
    tag_mode == 2 || (tag_mode == 1 && chap_index < 64)
  end

  # class_getter library : Set(String) do
  #   inp_dir = "_db/vi_users/marks"
  #   bhashes = Dir.children(inp_dir).map { |x| File.basename(x, ".tsv") }
  #   Set(String).new(bhashes)
  # end

  # def self.should_tag?(bhash : String, favi = false)
  #   return true unless favi
  #   library.includes?(bhash)
  # end
end

wrks, mode, redo = 6, 1, false

OptionParser.parse(ARGV) do |opt|
  opt.banner = "Usage: invoke-pkuseg [arguments]"
  opt.on("-t THREADS", "Parallel workers") { |x| wrks = x.to_i }
  opt.on("-m MODE", "Less or more chaps") { |x| mode = x.to_i }
  opt.on("-r", "Redo postagging") { redo = true }
end

# wrks = files.size if wrks > files.size
wrks = 1 if wrks < 1
chan = Channel(Nil).new(wrks)

lines = File.read_lines("priv/zhseed.tsv").reject(&.empty?)

lines.first(20000).each_with_index(1) do |line, idx|
  chan.receive if idx > wrks

  spawn do
    sname, snvid, bhash, bslug = line.split('\t')
    puts "- <#{idx}/#{lines.size}> [#{sname}/#{snvid}] #{bslug}".colorize.yellow
    tagger = CV::Tagger.new(sname, snvid, redo: redo)
    tagger.run!(mode: mode)
  rescue err
    puts err.message.colorize.red
  ensure
    chan.send(nil)
  end
end

wrks.times { chan.receive }
