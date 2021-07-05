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

  def init!(wrks = 3)
    files = extract_txt(tag_mode: 1)
    postag_files(files, wrks: wrks)
  end

  def extract_txt(tag_mode = 1) : Array(String)
    zip_files = Dir.glob("#{@inp_dir}/*.zip")
    tag_mode = 2 if zip_files.size < 3 # parse all if total chapters < 200

    FileUtils.mkdir_p(@out_dir)
    output = [] of String

    zip_files.each do |zip_file|
      output.concat extract_zip(zip_file, tag_mode: tag_mode)
      tag_mode = 0 if tag_mode == 1 # reset tag_mode unless tagging all
    end

    output
  end

  def extract_zip(zip_file : String, tag_mode = 0) : Array(String)
    res = [] of String

    Compress::Zip::File.open(zip_file) do |file|
      file.entries.each_with_index do |entry, index|
        next unless should_tag?(tag_mode, index)
        txt_file = File.join(@out_dir, entry.filename)

        tag_file = txt_file.sub(".txt", ".dat")
        next if !@redo && File.exists?(tag_file)

        entry.open { |io| File.write(txt_file, io.gets_to_end) }
        res << txt_file
      end
    end

    res
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

  def postag_files(files : Array(String), wrks = 3)
    return if files.empty?
    puts "[ To be tagged: #{files.size} files ]".colorize.yellow

    wrks = files.size if wrks > files.size
    chan = Channel(Nil).new(wrks)

    files.each_with_index(1) do |file, idx|
      spawn do
        add_postag(file, label: "#{idx}/#{files.size}")
      rescue err
        puts err.message.colorize.red
      ensure
        chan.send(nil)
      end

      chan.receive if idx > wrks
    end

    wrks.times { chan.receive }
  end

  def add_postag(txt_file : String, label = "1/1") : Nil
    raise "File #{txt_file} not found!" unless File.exists?(txt_file)
    tag_file = txt_file.sub(".txt", ".dat")

    cap = "#{@sname}/#{@snvid}/#{File.basename(txt_file)}"
    res = `python3 tasks/postag/pkuseg-runner.py "#{txt_file}" "#{tag_file}"`
    puts "- <#{label}> [#{cap}] #{res.sub("\t", "  ")}".colorize.blue

    raise "Output #{tag_file} not found!" unless $?.success? && File.exists?(tag_file)
    File.delete(txt_file)
  end
end

wrks, mode, redo = 5, 1, false

OptionParser.parse(ARGV) do |opt|
  opt.banner = "Usage: invoke-pkuseg [arguments]"
  opt.on("-t THREADS", "Parallel workers") { |x| wrks = x.to_i }
  opt.on("-m MODE", "Less or more chaps") { |x| mode = x.to_i }
  opt.on("-r", "Redo postagging") { redo = true }
end

lines = File.read_lines("priv/zhseed.tsv")
lines.each_with_index(1) do |line, idx|
  parts = line.split('\t')
  next if parts.size < 4

  sname, snvid, _, bslug = parts
  puts "- <#{idx}/#{lines.size}> [#{sname}/#{snvid}] #{bslug}"

  tagger = CV::Postag.new(sname, snvid, redo: redo)
  tagger.init!
end
