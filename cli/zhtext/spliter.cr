require "icu"
require "file_utils"
require "colorize"

class Cvtxt::Split
  property split_mode : Int32

  def initialize(@file : String, @split_mode = 1, encoding : String? = nil)
    @input = read_utf8(file)
  end

  def read_utf8(file : String, encoding : String? = nil, csdet_limit = 500)
    File.open(file, "r") do |io|
      unless encoding
        encoding = CSDET.detect(io.read_string(csdet_limit)).name
        io.rewind
      end

      io.set_encoding(encoding, invalid: :skip)
      io.gets_to_end
    end
  end

  def split(file : String)
    return puts "#{file} không tồn tại, mời kiểm tra lại!" unless File.exists?(file)

    bname = File.basename(file, ".txt")
    out_dir = File.join("texts", bname)

    input = File.read(file, encoding: encoding, invalid: :skip)
    parts = split_chaps(input)
    chaps = parse_chaps(parts)

    puts "- Số chương: #{chaps.size}".colorize.cyan

    save_output(chaps, out_dir)
  end

  SPLIT_RE_0 = /^\/{3,}/m
  SPLIT_RE_1 = /(\r?\n|\r){2,}(?=\P{Zs})/m
  SPLIT_RE_2 = /(\r?\n|\r)(?=\P{Zs})/m
  SPLIT_RE_3 = /^\s*(?=第[零〇一二两三四五六七八九十百千]+章\s)/m

  property split_re_x = Regex.new("\r\n\r\n\r\n")

  def split_chaps(input : String) : Array(String)
    case split_mode
    when 0 then input.split(SPLIT_RE_0)
    when 1 then input.split(SPLIT_RE_1)
    when 2 then input.split(SPLIT_RE_2)
    when 3 then input.split(SPLIT_RE_3)
    else        input.split(split_re_x)
    end
  end

  class Chap
    property chvol = ""
    property lines = [] of String

    def initialize(@chvol, @lines)
    end
  end

  def parse_chaps(parts : Array(String))
    chaps = [] of Chap
    chvol = ""

    parts.each do |input|
      lines = input.split(/\r?\n|\r+/).map!(&.strip).reject!(&.empty?)
      next if lines.empty?

      if lines.size == 1
        if (last = chaps.last?) && (last.lines.empty?)
          puts "Phương pháp phân tách không đúng".colorize.red
          puts "curr: #{lines.first}"
          puts "prev: #{last.chvol}"
          exit 0
        end

        chvol = lines.first
        chaps << Chap.new(chvol, [] of String)
      elsif (last = chaps.last?) && last.lines.empty?
        last.lines = lines
      else
        chaps << Chap.new(chvol, lines)
      end
    end

    # TODO: check chaps valid?
    chaps
  end

  def save_output(chaps : Array(Chap), out_dir : String)
    FileUtils.rm_rf(out_dir)
    Dir.mkdir_p(out_dir)

    chaps.each_slice(20).with_index do |slice, idx|
      file = "#{out_dir}/#{idx}.txt"
      puts "- Lưu #{slice.size} chương vào file: #{file}".colorize.green

      File.open(file, "w") do |io|
        slice.each do |chap|
          io.print "/// #{chap.chvol}\n\n"

          chap.lines.each_with_index do |line, idx|
            io.puts(line)
            io.puts if idx == 0
          end

          io.print "\n\n"
        end
      end
    end
  end
end
