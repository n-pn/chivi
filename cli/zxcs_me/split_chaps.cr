require "colorize"
require "file_utils"
require "compress/zip"

require "icu"
require "../../src/tabkv/value_map"

class CV::Zxcs::SplitText
  struct Chap
    property label : String
    property lines : Array(String)

    def initialize(@label, @lines)
    end
  end

  INP_RAR = "_db/.cache/zxcs_me/.rars"
  INP_TXT = "_db/.cache/zxcs_me/texts"

  OUT_TXT = "_db/ch_texts/origs/zxcs_me"
  OUT_IDX = "_db/ch_infos/origs/zxcs_me"

  getter checked : ValueMap { ValueMap.new("_db/_seeds/zxcs_me/_texts.tsv") }
  getter csdet = ICU::CharsetDetector.new

  def extract_rars!
    input = Dir.glob("#{INP_RAR}/*.rar").sort_by { |x| File.basename(x, ".rar").to_i }
    input.each_with_index(1) do |rar_file, idx|
      next if File.size(rar_file) < 1000

      snvid = File.basename(rar_file, ".rar")
      out_txt = "#{INP_TXT}/#{snvid}.txt"
      next if File.exists?(out_txt)

      puts "\n- <#{idx}/#{input.size}> extracting #{rar_file.colorize.blue}"

      tmp_dir = ".tmp/#{snvid}"
      FileUtils.mkdir_p(tmp_dir)

      `unrar e -o+ "#{rar_file}" #{tmp_dir}`
      inp_txt = Dir.glob("#{tmp_dir}/*.txt").first? || Dir.glob("#{tmp_dir}/*.TXT").first

      lines = read_clean(inp_txt)
      File.write(out_txt, lines.join("\n"))

      FileUtils.rm_rf(tmp_dir)
    rescue err
      puts err
    end
  end

  FILE_RE_1 = /《(.+)》.+作者：(.+)\./
  FILE_RE_2 = /《(.+)》(.+)\.txt/

  def read_clean(inp_file : String) : Array(String)
    lines = read_as_utf8(inp_file).strip.split(/\r\n?|\n/)

    if lines.first.starts_with?("===")
      3.times { lines.shift; lines.pop }

      lines.shift if lines.first.starts_with?("===")
      lines.pop if lines.last.starts_with?("===")
    end

    if match = FILE_RE_1.match(inp_file) || FILE_RE_2.match(inp_file)
      _, title, author = match
      while is_garbage?(lines.first, title, author)
        lines.shift
      end
    else
      exit(0)
    end

    while is_garbage_end?(lines.last)
      lines.pop
    end

    # puts lines.first(3).join("\n"), "\n---\n", lines.last(3).join("\n")

    lines
  end

  private def read_as_utf8(txt_file : String)
    File.open(txt_file, "r") do |f|
      str = f.read_string(500)
      csm = csdet.detect(str)
      puts "- [#{File.basename txt_file}] encoding: #{csm.name} (#{csm.confidence})".colorize.green

      f.rewind
      f.set_encoding(csm.name, invalid: :skip)
      f.gets_to_end
    end
  end

  private def is_garbage?(line : String, title : String, author : String)
    return true if is_garbage_end?(line)
    case line
    when .=~(/^#{title}/),
         .=~(/《#{title}》/),
         .=~(/书名[：:]#{title}/),
         .=~(/作者[：:]#{author}/),
         .=~(/^分类：/)
      true
    else
      false
    end
  end

  private def is_garbage_end?(line : String)
    line.empty? || line.starts_with?("更多精校小说")
  end

  def extract!
    input = Dir.glob("#{INP}/*.txt").sort_by { |x| File.basename(x, ".txt").to_i }
    input.each_with_index(1) do |file, idx|
      extract_text!(file, "#{idx}/#{input.size}")
    end
  end

  def split_chaps!(inp_file : String, label = "1/1")
    snvid = File.basename(inp_file, ".txt")
    out_dir = "#{OUT}/#{snvid}"

    state, extra = checked.get(snvid) || ["", ""]

    input = File.read(inp_file).strip.split(/\r|\r?\n/)
    puts "\n- <#{label}> [#{INP}/#{snvid}.txt] #{input.size} lines".colorize.yellow

    return unless chaps = split_chapters(input)
    return unless chaps = cleanup_content(chaps)

    FileUtils.mkdir_p(out_dir)

    index = [] of String
    chaps.each_slice(100).with_index do |slice, idx|
      out_zip = File.join(out_dir, idx.to_s.rjust(3, '0') + ".zip")

      File.open(out_zip, "w") do |file|
        Compress::Zip::Writer.open(file) do |zip|
          slice.each_with_index(1) do |chap, chidx|
            chidx = chidx + 100 * idx
            schid = chidx.to_s.rjust(4, '0')

            zip.add("#{schid}.txt", chap.lines.join('\n'))
            index << {chidx, schid, chap.lines[0], chap.label}.join('\t')
          end
        end
      end
    end

    save_index!(index, "#{IDX}/#{snvid}.tsv")

    if good_enough?(index)
      return puts "\nSeems good enough, skipping prompt!".colorize.green
    end

    print "\nChoice (d: delete, s: delete and shutdown, else: continue): "

    case char = gets.try(&.strip)
    when "d", "s"
      FileUtils.rm_rf(out_dir)
      puts "- Folder #{out_dir} removed!".colorize.red
      exit(0) if char == "s"
    end
  end

  def save_index!(index : Array(String), out_file : String)
    puts "\n[ first chaps: ]"
    puts index.first(5).join("\n").colorize.blue
    puts "\n[ last chaps: ]"
    puts index.last(5).join("\n").colorize.blue

    File.write(out_file, index.join("\n"))
  end

  def good_enough?(index : Array(String))
    idx, _, title, _ = index.last.split('\t')
    title.includes?("第#{idx}章")
  end

  def split_chapters(input : Array(String))
    input = input[3...-3] if input[0].starts_with?("====")

    while is_garbage?(input.first)
      input.shift
    end

    blanks, nested = 0, false

    input.each_with_index do |line, idx|
      return if idx > 100

      is_blanks, blanks = blanks?(line, blanks)
      return split_blanks(input) if is_blanks

      nested ||= nested?(line) unless nested
    end

    return split_nested(input) if nested
  end

  def blanks?(line : String, prev = 0)
    line.empty? ? {prev > 1, prev + 1} : {false, 0}
  end

  def nested?(line : String)
    line =~ /^[　\s]{2,}/
  end

  def split_blanks(input : Array(String))
    chaps = [] of Array(String)
    lines = [] of String

    blank = 0

    input.each do |line|
      line = line.strip

      if line.empty?
        blank += 1
        next
      end

      if blank > 1 && !lines.empty?
        chaps << lines
        lines = [] of String
      end

      blank = 0
      lines << line
    end

    chaps << lines unless lines.empty?

    puts "[ splited blanks: #{chaps.size} chaps]".colorize.cyan
    chaps
  end

  def split_nested(input : Array(String))
    chaps = [] of Array(String)
    lines = [] of String

    input.each do |line|
      next if line.empty?

      if nested?(line)
        line = line.strip
      elsif !lines.empty?
        chaps << lines
        lines = [] of String
      end

      lines << line
    end

    chaps << lines unless lines.empty?

    puts "[ splited nested: #{chaps.size} chaps]".colorize.cyan
    chaps
  end

  def cleanup_content(input : Array(Array(String)))
    while is_intro?(input.first)
      input.shift
    end

    chaps = [] of Chap
    label = ""

    input.each do |lines|
      if lines.size == 1
        label = lines.first
      else
        chaps << Chap.new(label, lines)
      end
    end

    chaps
  end

  def is_intro?(chap : Array(String))
    return true if chap.last =~ /^作者：/

    case chap.first
    when .includes?("作品简介"),
         .includes?("作者简介"),
         .includes?("内容简介"),
         .includes?("内容介绍"),
         .includes?("内容说明")
      true
    else
      false
    end
  end
end

worker = CV::Zxcs::SplitText.new
worker.extract_rars!
