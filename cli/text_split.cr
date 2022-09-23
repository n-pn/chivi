require "option_parser"

class SplitArgs
  property init_ch_no = 1
  property init_chvol = ""

  property split_mode = 1

  # for mode 0
  property min_repeat = 3

  # for mode 1
  property trim_space = false
  property min_blanks = 2

  # for mode 2
  property need_blank = false

  # for mode 3
  property title_suffix = "章节回幕折集卷季"

  # for mode 4
  property custom_regex = "^\\s*第?[\\d+零〇一二两三四五六七八九十百千]+章"

  def initialize
  end

  def self.from_file(file : String)
    new.tap(&.load_file(file))
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def load_file(file : String)
    File.each_line(file) do |line|
      data = line.split('\t', 2)
      next if data.size < 2

      key, val = data

      case key
      when "init_ch_no"   then @init_ch_no = val.to_i
      when "init_chvol"   then @init_chvol = val
      when "split_mode"   then @split_mode = val.to_i
      when "min_repeat"   then @min_repeat = val.to_i
      when "trim_space"   then @trim_space = val[0] == 't'
      when "min_blanks"   then @min_blanks = val.to_i
      when "need_blank"   then @need_blank = val[0] == 't'
      when "title_suffix" then @title_suffix = val
      when "custom_regex" then @custom_regex = val
      end
    end
  end
end

class ChapData
  property ch_no = 0

  property chvol = ""
  property title = ""

  getter paras = [] of String
  getter sizes = [] of Int32

  getter c_len : Int32 = 0
  getter p_len : Int32 = 0

  getter parts : Array(String) { split_parts }

  def initialize(@ch_no, @chvol = "")
  end

  def add_line(line : String) : Nil
    return if line.blank?

    if @title.empty?
      @title = line
    else
      @paras << line

      c_len = line.size
      @sizes << c_len
      @c_len += c_len
    end
  end

  CHAR_LIMIT = 3000

  private def split_parts : Array(String)
    if @c_len <= CHAR_LIMIT * 1.5
      @p_len = 1
    else
      @p_len = (@c_len - 1) // CHAR_LIMIT + 1
    end

    return [@paras.join('\n')] if @p_len == 1

    output = [] of String
    char_limit = @c_len // @p_len

    buffer = String::Builder.new(@title)
    char_count = 0

    @paras.each_with_index do |para, idx|
      buffer << '\n' << para

      char_count += @sizes.unsafe_fetch(idx)
      next if char_count < char_limit

      output << buffer.to_s
      buffer = String::Builder.new(@title)
      char_count = 0
    end

    output << buffer.to_s if char_count > 0

    raise "wrong output" if output.size != @p_len
    output
  end

  def save!(save_dir : String) : Nil
    parts.each_with_index do |text, part|
      file_path = "#{save_dir}/#{@ch_no}-#{part}.txt"
      File.write(file_path, text)
    end
  end
end

class SplitText
  getter args : SplitArgs

  getter txt_file : String
  getter save_dir : String

  getter raw_data : Array(String)
  getter out_data = [] of ChapData

  @curr_chvol : String

  def initialize(@txt_file)
    args_file = txt_file.sub(".txt", ".arg")
    @args = SplitArgs.from_file(args_file)

    @save_dir = extract_save_dir_from_txt_file(txt_file)
    @raw_data = read_and_clean_text(txt_file)

    @curr_chvol = clean_text(@args.init_chvol)
  end

  private def extract_save_dir_from_txt_file(txt_file : String) : String
    paths = txt_file.split('/')

    sname = paths[-2]
    s_bid = paths[-1].split(/[\-\.]/, 2).first

    File.join("var/chtexts", sname, s_bid)
  end

  private def read_and_clean_text(inp_file : String) : Array(String)
    lines = File.read(inp_file).gsub(/\r\n?/, '\n').split('\n')
    lines[0] = lines[0].tr("\uFEFF", "")
    lines
  end

  def split_text! : Nil
    case @args.split_mode
    when 0 then split_mode_0(@args.min_repeat)
    when 1 then split_mode_1(@args.trim_space, @args.min_blanks)
    when 2 then split_mode_2(@args.need_blank)
    when 3 then split_mode_3(@args.title_suffix)
    when 4 then split_mode_4(@args.custom_regex)
    else        raise "Chế độ chia chưa được hỗ trợ!"
    end
  end

  # split by manually putting `///` between chaps
  private def split_mode_0(min_repeat = 3)
    split_mark_regex = /^\/{#{min_repeat},}(.*)$/
    pending_chap = init_chap

    @raw_data.each do |line|
      line = clean_text(line)

      if match = line.match(split_mark_regex)
        push_chap(pending_chap) # add previous chapter

        @curr_chvol = match[1] unless match[1].empty?
        pending_chap = init_chap
      else
        pending_chap.add_line(line)
      end
    end

    push_chap(pending_chap)
  end

  # split if there is `min_blanks` number of adjacent blank lines
  private def split_mode_1(trim_space = false, min_blanks = 2)
    blank_count = 0

    split_text do |line|
      line = clean_text(line) if trim_space

      if line.empty?
        blank_count += 1
        blank_count >= min_blanks
      else
        blank_count = 0
        false
      end
    end
  end

  # split if body is padded with spaces
  private def split_mode_2(need_blank = false)
    prev_was_blank = true
    blank_chars = {' ', '　', '\t'}

    split_text do |line|
      if line.blank?
        prev_was_blank = true
        false
      elsif line[0].in?(blank_chars)
        false
      else
        is_new_chap = prev_was_blank || !need_blank
        prev_was_blank = false
        is_new_chap
      end
    end
  end

  # split by chapter
  private def split_mode_3(suffixes : String)
    split_mode_4("^[ 　]*第[\\d零〇一二两三四五六七八九十百千]+[#{suffixes}]")
  end

  private def split_mode_4(regex_str : String)
    regex = Regex.new(regex_str)
    split_text { |line| line =~ regex }
  end

  private def split_text
    prev_was_chvol = false
    pending_chap = init_chap

    @raw_data.each_with_index(1) do |line, idx|
      is_new_chap = yield line # check if this is the mark of new pending_chap
      line = clean_text(line)

      if !is_new_chap
        pending_chap.add_line(line)
        prev_was_chvol = false
      elsif pending_chap.paras.size > 0
        push_chap(pending_chap)

        pending_chap = init_chap
        pending_chap.title = line

        prev_was_chvol = false
      elsif prev_was_chvol
        raise "Lỗi dòng: #{idx} [#{line[0..10]}]: Chương phía trước không có nội dung."
      elsif pending_chap.title.empty?
        pending_chap.title = line
        prev_was_chvol = false
      else
        @curr_chvol = pending_chap.chvol = pending_chap.title
        pending_chap.title = line
        prev_was_chvol = true
      end
    end

    push_chap(pending_chap)
  end

  ####

  private def clean_text(input : String)
    input.tr("\t\u00A0\u2002\u2003\u2004\u2007\u2008\u205F\u3000", " ").strip
  end

  private def init_chap
    ch_no = @args.init_ch_no + @out_data.size
    ChapData.new(ch_no, @curr_chvol)
  end

  MAX_CHAP_CHARS = 100000 # aroudn 30 parts
  MAX_CHAP_COUNT =   4000

  private def push_chap(chapter : ChapData)
    return if chapter.title.empty?

    if chapter.c_len > MAX_CHAP_CHARS
      p_len = chapter.c_len // 3000 + 1
      raise "Só lượng phần của chương số #{chapter.ch_no} vượt quá giới hạn (#{p_len}/30)"
    end

    if @out_data.size > MAX_CHAP_COUNT
      raise "Số lượng chương vượt quá giới hạn (#{@out_data.size}/#{MAX_CHAP_COUNT})"
    end

    @out_data << chapter
  end

  ###

  def save_texts!
    groups = @out_data.group_by { |x| (x.ch_no &- 1) // 128 }

    groups.each do |group, chaps|
      base_path = "#{@save_dir}/#{group}"
      Dir.mkdir_p(base_path)

      chaps.each(&.save!(base_path))
      message = `zip -rjmq "#{base_path}.zip" "#{base_path}"`

      raise message unless $?.success?
      Dir.delete(base_path)
    end
  end

  def save_infos!(mtime : Int64, uname : String)
    split_out = File.open(@txt_file.sub(".txt", ".tsv"), "w")
    patch_out = File.open(File.join(@save_dir, "patch.tab"), "a")

    @out_data.each do |chap|
      info = {
        chap.ch_no, chap.ch_no, chap.title, chap.chvol,
        mtime, chap.c_len, chap.p_len, uname,
      }

      split_out.puts(info.join('\t'))
      patch_out.puts(info.join('\t'))
    end

    split_out.close
    patch_out.close
  end

  ###

  def self.run!(argv = ARGV)
    input = argv[0]
    uname = argv[1]? || ""
    mtime = argv[2]?.try(&.to_i64?) || Time.utc.to_unix

    task = new(input)
    task.split_text!

    task.save_texts!
    task.save_infos!(mtime, uname)

    last_chap = task.out_data.last
    STDOUT.puts last_chap.ch_no
  end

  run!
end
