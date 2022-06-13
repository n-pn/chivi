require "icu"
require "colorize"
require "option_parser"

require "../src/mtlv1/mt_core"
require "../src/appcv/nvchap/ch_list"

class Chapter
  getter lines = [] of String

  getter sizes = [] of Int32
  getter chars = 0
  getter parts = 1

  def <<(line : String)
    size = line.size
    @chars += size
    @sizes << size
    @lines << line
  end

  CHAR_LIMIT = 3000

  def save!(base_path : String) : Nil
    if @chars <= CHAR_LIMIT * 1.5
      return File.write("#{base_path}-0.txt", @lines.join('\n'))
    end

    @parts = (@chars / CHAR_LIMIT).round.to_i
    break_point = @chars // @parts

    title = @lines[0]
    buffer = String::Builder.new(title)

    char_count, chap_part = 0, 0

    1.upto(@lines.size &- 1) do |idx|
      buffer << '\n' << @lines.unsafe_fetch(idx)

      char_count += @sizes.unsafe_fetch(idx)
      next if char_count < break_point

      File.write("#{base_path}-#{chap_part}.txt", buffer.to_s)
      chap_part &+= 1

      buffer = String::Builder.new(title)
      char_count = 0
    end

    File.write("#{base_path}-#{chap_part}.txt", buffer.to_s) if char_count > 0
  end
end

class Splitter
  property inp_file = ""
  property log_file : String { @inp_file.sub(".txt", ".log") }
  property chap_dir : String { File.dirname(@inp_file).sub("chseeds", "chtexts") }

  property uname = ""
  property chvol = ""
  property chidx = 1

  getter lines = [] of String
  getter infos = [] of CV::ChInfo

  def log_state(message : String, abort = false)
    File.open(log_file, "a", &.puts(message))
    return unless abort
    puts message
    exit 1
  end

  def load_input!(to_simp = false, un_wrap = false, encoding : String? = nil)
    input = read_utf8(@inp_file, encoding)

    input = CV::MtCore.trad_to_simp(input) if to_simp

    if un_wrap
      input = input.gsub(/(?=[^\n]{30,}[，\P{P}])[\n\s　]+/m, "")
    end

    @lines = input.split('\n')
    log_state("\n#{Time.local}\n- #{@lines.size} lines loaded")
    lines[0] = lines[0].tr("\uFEFF", "")
  end

  def read_utf8(inp_file : String, encoding : String? = nil, chardet_limit = 1000) : String
    File.open(inp_file, "r") do |io|
      unless encoding
        chunk = io.read_string(chardet_limit)
        io.rewind

        chardet = ICU::CharsetDetector.new
        encoding = chardet.detect(chunk).name
      end

      io.set_encoding(encoding, invalid: :skip)
      io.gets_to_end.gsub(/\r?\n|\r/, '\n')
    end
  end

  def save_chapter(entry : Chapter) : Nil
    return if entry.lines.empty?

    schid = "#{@chidx}_#{@infos.size + 1}"

    index = @chidx &+ @infos.size
    group = (index &- 1) // 128

    group_dir = "#{chap_dir}/#{group}"
    Dir.mkdir_p(group_dir)

    entry.save!("#{group_dir}/#{schid}")

    chinfo = CV::ChInfo.new(index, schid, entry.lines[0], @chvol)

    stats = chinfo.stats
    stats.utime = Time.utc.to_unix
    stats.uname = @uname

    stats.chars = entry.chars
    stats.parts = entry.parts

    @infos << chinfo
  end

  def save_chlists(chlist = @infos) : Nil
    if message = invalid_chlist?
      # groups = chlist.map(&.chidx.&-(1).// 128).to_set
      # groups.each { |group| `rm -rf "#{chap_dir}/#{group}"` }

      return log_state(message, abort: true)
    end

    chlist.group_by(&.chidx.&-(1).// 128).each do |group, slice|
      group_dir = "#{chap_dir}/#{group}"

      message = `zip --include=\\*.txt -rjmq "#{group_dir}.zip" "#{group_dir}" && rm -rf #{group_dir}`
      log_state(message, abort: true) unless $?.success?

      chlist = CV::ChList.new("#{group_dir}.tsv")
      chlist.patch(slice)

      chlist.save!
    end
  end

  def invalid_chlist?(chlist = @infos)
    if chlist.size > 4000
      return "Lỗi chia: số lượng chương quá nhiều (#{chlist.size} chương)"
    end

    chlist.each do |chinfo|
      parts = chinfo.stats.parts
      return "Lỗi chia: chương số #{chinfo.chidx} có quá nhiều phần (#{parts} phần)" if parts > 30
    end
  end

  def split_chap
    chapter = Chapter.new
    prev_was_chvol = false

    @lines.each_with_index(1) do |line, idx|
      mark_new_chap = yield line # check if this is the mark of new chapter
      line = clean_text(line)

      if !mark_new_chap
        prev_was_chvol = false
        chapter << line unless line.empty?
      elsif chapter.lines.size != 1
        # previous chapter do not contain just a single line
        prev_was_chvol = false
        save_chapter(chapter)

        chapter = Chapter.new
        chapter << line unless line.empty?
      elsif prev_was_chvol
        message = "Lỗi: Chương phía trước không có nội dung. Phát hiện lỗi ở dòng #{idx}: #{line}."
        log_state(message, abort: true)
      else
        @chvol = chapter.lines[0]
        prev_was_chvol = true
      end
    end

    save_chapter(chapter)
    save_chlists(@infos)
  end

  def clean_text(input : String)
    input.tr("\t\u00A0\u2002\u2003\u2004\u2007\u2008\u205F\u3000", " ").strip
  end

  # SPLIT_RE_0 = /^\/{3,}/m
  # SPLIT_RE_1 = /(\r?\n|\r){2,}(?=\P{Zs})/m
  # SPLIT_RE_2 = /(\r?\n|\r)(?=\P{Zs})/m
  # SPLIT_RE_3 = /^\s*(?=第[零〇一二两三四五六七八九十百千]+章\s)/m

  # split by manually putting `///` between chaps
  def split_mode_0
    log_state("- Split mode: 0")
    chapter = Chapter.new

    @lines.each do |line|
      if match = line.match(/^\s*\/{3,}(.*)/)
        save_chapter(chapter)
        chapter = Chapter.new

        chvol = clean_text(match[1])
        @chvol = chvol unless chvol.empty?
      else
        line = clean_text(line)
        chapter << line unless line.empty?
      end
    end

    save_chapter(chapter)
    save_chlists(@infos)
  end

  # split if there is `min_blank_line` number of adjacent blank lines
  def split_mode_1(min_blank_line = 2, ignore_whitespace = false)
    log_state("- Split mode: 1, min_blank: #{min_blank_line}, no_space: #{ignore_whitespace}")

    blank_count = 0

    split_chap do |line|
      line = clean_text(line) if ignore_whitespace

      if line.empty?
        blank_count &+= 1
        blank_count >= min_blank_line
      else
        blank_count = 0
        false
      end
    end
  end

  # split if there is `min_blank_line` number of adjacent blank lines
  def split_mode_2(require_blank_line = false)
    log_state("- Split mode: 2, require_blank_before: #{require_blank_line}")

    was_blank_line = true

    split_chap do |line|
      unless line =~ /\P{Zs}/
        was_blank_line = line.blank?
        next false
      end

      is_new_chap, was_blank_line = !require_blank_line || was_blank_line, false
      is_new_chap
    end
  end

  def split_mode_3(suffixes : String)
    log_state("- Split mode: 3, suffixes: #{suffixes}")
    log_state("Lỗi nhập: Không có nhãn chương", abort: true) if suffixes.empty?

    regex = Regex.new("^[ 　]*第[\\d零〇一二两三四五六七八九十百千]+[#{suffixes}]")
    split_by_regex(regex)
  end

  def split_mode_4(regex : String)
    log_state("- Split mode: 4, regex: #{regex}")
    split_by_regex(Regex.new(regex))
  end

  def split_by_regex(regex : Regex)
    log_state("- Regex used: #{regex}")
    split_chap { |line| line =~ regex }
  end
end

cmd = Splitter.new

to_simp = false
un_wrap = false
encoding = nil
split_mode = 1

min_blank_line = 2

trim_whitespace = false
need_blank_before = false

title_suffixes = "章节回幕折集卷季"

custom_regex = "^\\s*第?[\\d+零〇一二两三四五六七八九十百千]+章"

OptionParser.parse do |parser|
  parser.on("-i INPUT", "input file") { |i| cmd.inp_file = i }
  parser.on("--tosimp", "trad to simp") { to_simp = true }
  parser.on("--unwrap", "fix line breaking") { un_wrap = true }
  parser.on("-e ENCODING", "file encoding") { |e| encoding = e }

  parser.on("-u UNAME", "user name") { |u| cmd.uname = u }
  parser.on("-v CHVOL", "default chapter volume name") { |v| cmd.chvol = v }
  parser.on("-f CHIDX", "start chap index") { |f| cmd.chidx = f.to_i }
  parser.on("-d CHAP_DIR", "output folder") { |i| cmd.chap_dir = i }

  parser.on("-m SPLIT_MODE", "text split mode") { |m| split_mode = m.to_i }

  # for mode 2
  parser.on("--trim", "ignore whitespace on mode 2") { trim_whitespace = true }
  parser.on("--min-blank MIN", "minimum blank line to seperate") { |min| min_blank_line = min.to_i }

  # for mode 3
  parser.on("--blank-before", "require blank line before new chap") { need_blank_before = true }

  # for mode 4
  parser.on("--suffix SUFFIXES", "title suffixes indication") { |x| title_suffixes = x }

  # for mode 5
  parser.on("--regex REGEX", "custom regex for splitting") { |x| custom_regex = x }
end

cmd.load_input!(to_simp, un_wrap, encoding)

case split_mode
when 0 then cmd.split_mode_0
when 1 then cmd.split_mode_1(min_blank_line, trim_whitespace)
when 2 then cmd.split_mode_2(need_blank_before)
when 3 then cmd.split_mode_3(title_suffixes)
when 4 then cmd.split_mode_4(custom_regex)
else
  puts "Chế độ chia #{split_mode} chưa được hỗ trợ"
  exit(1)
end

last = cmd.infos.last
cmd.log_state("\nSuccess! chap_count: #{cmd.infos.size}, \
                from_idx: #{cmd.chidx}, \
                last_idx: #{last.chidx}")
puts "#{last.chidx}\t#{last.schid}"
