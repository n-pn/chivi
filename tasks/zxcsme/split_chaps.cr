require "colorize"
require "file_utils"
require "compress/zip"

require "../../src/_util/file_util"
require "../../src/appcv/filedb/*"

class CV::Zxcs::SplitText
  struct Chap
    property label : String
    property lines : Array(String)
    getter title : String { lines[0]? || "" }

    def initialize(@label, @lines)
    end
  end

  INP_RAR = "_db/.keeps/zxcs_me/_rars"
  INP_TXT = "_db/.keeps/zxcs_me/texts"

  OUT_DIR = "db/chtexts/zxcs_me"

  def extract_all!
    input = Dir.glob("#{INP_RAR}/*.rar").shuffle
    output = [] of String

    input.each_with_index(1) do |rar_file, idx|
      next unless file = extract_rar!(rar_file, label: "#{idx}/#{input.size}")
      output << file
    end

    `python3 tasks/zxcsme/fix_mtime.py`

    output.each_with_index do |file, idx|
      split_chaps!(file, "#{idx}/#{output.size}")
    end
  end

  def extract_rar!(rar_file : String, label = "1/1")
    return if File.size(rar_file) < 1000

    snvid = File.basename(rar_file, ".rar")
    out_txt = "#{INP_TXT}/#{snvid}.txt"

    return out_txt if File.exists?(out_txt)
    puts "\n- <#{label}> extracting #{rar_file.colorize.blue}"

    tmp_dir = "tmp/#{snvid}"
    FileUtils.mkdir_p(tmp_dir)

    `unrar e -o+ "#{rar_file}" #{tmp_dir}`
    inp_txt = Dir.glob("#{tmp_dir}/*.txt").first? || Dir.glob("#{tmp_dir}/*.TXT").first

    lines = read_clean(inp_txt)
    File.write(out_txt, lines.join("\n"))

    FileUtils.rm_rf(tmp_dir)
    out_txt
  rescue err
    puts err
  end

  FILE_RE_1 = /《(.+)》.+作者：(.+)\./
  FILE_RE_2 = /《(.+)》(.+)\.txt/

  private def read_clean(inp_file : String) : Array(String)
    lines = FileUtil.read_utf8(inp_file).strip.split(/\r\n?|\n/)

    if lines.first.starts_with?("===")
      3.times { lines.shift; lines.pop }

      lines.shift if lines.first.starts_with?("===")
      lines.pop if lines.last.starts_with?("===")
    end

    if match = FILE_RE_1.match(inp_file) || FILE_RE_2.match(inp_file)
      _, title, author = match
    else
      exit(0)
    end

    while is_garbage?(lines.first, title, author)
      lines.shift
    end

    while is_garbage_end?(lines.last)
      lines.pop
    end

    lines
  end

  private def is_garbage?(line : String, title : String, author : String)
    return true if is_garbage_end?(line)

    case line
    when .=~(/^#{title}/),
         .=~(/《#{title}》/),
         .=~(/书名[：:]\s*#{title}/),
         .=~(/作者[：:]\s*#{author}/),
         .=~(/^分类：/),
         .=~(/^字数：：/)
      true
    else
      false
    end
  end

  private def is_garbage_end?(line : String)
    line.empty? || line.starts_with?("更多精校小说")
  end

  def split_chaps!(inp_file : String, label = "1/1")
    snvid = File.basename(inp_file, ".txt")

    out_dir = "#{OUT_DIR}/#{snvid}"
    out_idx = "#{out_dir}/0.tsv"

    return if File.exists?(out_idx)

    FileUtils.mkdir_p(out_dir)
    input = File.read(inp_file).split(/\r\n?|\n/)

    # TODO: remove these hacks
    input = reclean_text!(inp_file, input)

    puts "\n- <#{label}> [#{INP_TXT}/#{snvid}.txt] #{input.size} lines".colorize.yellow

    return unless chaps = split_chapters(snvid, input)
    chaps = cleanup_chaps(chaps)

    index = chaps.map_with_index(1) do |chap, idx|
      [(idx + 1).to_s, chap.title, chap.label]
    end

    if good_enough?(index)
      save_texts!(chaps, out_dir, inp_file)
      return
    end

    puts "\n- <#{label}> [#{INP_TXT}/#{snvid}.txt] #{input.size} lines".colorize.yellow
    print "\nChoice (r: redo, d: delete, s: delete + exit, else: keep): "

    STDIN.flush
    case char = STDIN.raw(&.read_char)
    when 'd', 's', 'r'
      FileUtils.rm_rf(out_dir)
      puts "\n\n- [#{out_dir}] deleted! (choice: #{char})".colorize.red

      if char == 'r'
        split_chaps!(inp_file, label)
      elsif char == 's'
        exit(0)
      end
    else
      save_texts!(chaps, out_dir, inp_file)
      puts "\n\n- Entries [#{snvid}] saved!".colorize.yellow
    end
  end

  def reclean_text!(inp_file : String, lines : Array(String))
    changed = false

    if lines.first.match(/^\s*===/)
      changed = true

      3.times { lines.shift; lines.pop }

      lines.shift if lines.first.match(/^\s*===/)
      lines.pop if lines.last.match(/^\s*===/)
    end

    while lines.first.empty? || lines.first.match(/^分类：|作者：|类别：|字数：/)
      changed = true
      lines.shift
    end

    File.write(inp_file, lines.join("\n")) if changed
    lines
  rescue
    puts [inp_file, lines]
    exit(0)
  end

  def save_texts!(chaps, out_dir : String, inp_file : String)
    utime = File.info(inp_file).modification_time.to_s

    snvid = File.basename(out_dir)
    FileUtils.mkdir_p(out_dir)

    chaps.each_slice(128).with_index do |slice, idx|
      chlist = [] of String

      out_zip = File.join(out_dir, "#{idx}.zip")
      out_idx = "#{out_dir}/#{idx}.tsv"

      slice.each_with_index(1) do |chap, chidx|
        chidx = (chidx + 128 * idx)
        schid = chidx.to_s

        chinfo = Chpage.new([schid, chap.title, chap.label, utime], chidx)
        chtext = Chtext.new("zxcs_me", snvid, chinfo)

        chtext.save!(chap.lines, zipping: false)
        chlist << "#{schid}\t#{chinfo}"
      end

      `zip -jqm #{out_zip} #{out_dir}/*.txt`
      File.write(out_idx, chlist.join('\n'))
      puts "#{out_idx} saved!"
    end
  end

  private def split_chapters(snvid : String, lines : Array(String))
    case snvid
    when "4683", "3868", "4314", "3199", "4942", "1552"
      return split_blanks(lines)
    when "3401"
      return split_delimit(lines)
    end

    blanks_single, blanks_double, blanks_count = 0, 0, 0
    unnest_count, nested_count = 0, 0

    lines.each_with_index do |line, idx|
      break if idx > 1000

      if line.empty?
        blanks_count += 1
        next
      end

      if blanks_count > 1
        blanks_double += 1
      elsif blanks_count > 0
        blanks_single += 1
      end

      blanks_count = 0

      if nested?(line)
        nested_count += 1
      else
        unnest_count += 1
      end
    end

    return split_blanks(lines) if blanks_double > 1
    return split_nested(lines) if nested_count > 1 && unnest_count > 1

    if unnest_count == 0
      return split_delimit(lines) if blanks_single > 0
    end

    puts "-- [ unsupported file format, skipping! ]".colorize.cyan
    nil
  end

  private def nested?(line : String)
    line =~ /^[　\s]{2,}/
  end

  private def split_blanks(input : Array(String))
    chaps = [] of Array(String)
    lines = [] of String

    blank = 0

    input.each do |line|
      line = line.tr("　", " ").strip

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

    puts "-- [ splited blanks: #{chaps.size} chaps ]".colorize.cyan
    chaps
  end

  private def split_nested(input : Array(String))
    chaps = [] of Array(String)
    lines = [] of String

    input.each do |line|
      next if line.empty?

      unless lines.empty? || nested?(line)
        chaps << lines
        lines = [] of String
      end

      lines << line.strip
    end

    chaps << lines unless lines.empty?

    puts "-- [ splited nested: #{chaps.size} chaps ]".colorize.cyan
    chaps
  end

  private def split_delimit(input : Array(String))
    chaps = [] of Array(String)
    lines = [] of String

    prev_blank = false

    input.each do |line|
      if line.empty?
        if lines.size > 1
          chaps << lines
          lines = [] of String
        end
      else
        lines << line.strip
      end
    end

    chaps << lines unless lines.empty?

    puts "-- [ splited delimit: #{chaps.size} chaps ]".colorize.cyan
    chaps
  end

  def cleanup_chaps(input : Array(Array(String)))
    while is_intro?(input.first)
      input.shift
    end

    chaps = [] of Chap
    label = ""

    input.each do |lines|
      if lines.size == 1
        label = lines.first
      else
        chaps << Chap.new(label.strip, lines.map(&.strip))
      end
    end

    chaps
  end

  private def is_intro?(chap : Array(String))
    return true if chap.last =~ /^作者：/

    case chap.first
    when .includes?("简介："),
         .includes?("介绍："),
         .includes?("内容概要："),
         .includes?("作品介绍"),
         .includes?("作品简介"),
         .includes?("作者简介"),
         .includes?("内容简介"),
         .includes?("内容介绍"),
         .includes?("内容说明"),
         .includes?("书籍介绍"),
         .includes?("书籍简介"),
         .includes?("小说简介")
      true
    else
      false
    end
  end

  private def good_enough?(index : Array(Array(String)))
    idx, title, _ = index.last
    return true if title.includes?("第#{idx}章")

    bads = [] of String

    index.each do |info|
      _, title, label = info

      case label
      when "序", "外传", "番外", "外篇", "番外篇",
           "作品相关", "【作品相关】"
        next
      else
        if label.size > 20
          bads << "#{title} -- #{label}"
          next
        end
      end

      case title
      when "引言", "结束语", "引 子", "开始", "感言", "前言",
           "锲子", "结语", "楔子", "作者的话", "小结",
           .includes?("后记"),
           .includes?("完本了"),
           .includes?("作品相关"),
           .includes?("结束感言"),
           .includes?("完本感言"),
           .includes?("完结感言"),
           .includes?("完稿感言"),
           .includes?("完稿感言"),
           .includes?("结后感言"),
           .includes?("全本感言"),
           .includes?("次卷预告"),
           .includes?("写在结束的话"),
           .=~(/^【?(序|第|终卷|楔子|引子|尾声|番外|终章|末章|终曲|后记|后续|结局)/),
           .=~(/^【?(前记|篇外|前言|后篇|外传|尾章|初章|引章|卷末|最终回|最终章|终结章|终之章|大结局|人物介绍|更新说明)/),
           .=~(/^\d+、/),
           .=~(/^[【\[\(]\d+[】\]\)]/),
           .=~(/^章?[零〇一二两三四五六七八九十百千+]^/)
        next
      else
        bads << "#{title} -- #{label}"
      end
    end

    if bads.empty?
      puts "\nSeems good enough, skip checking!".colorize.green
      true
    else
      puts "\n- wrong format (#{bads.size}): ", bads.first(30).join("\n\n").colorize.red
      false
    end
  end
end

worker = CV::Zxcs::SplitText.new
worker.extract_all!
