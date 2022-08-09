require "colorize"

require "../../_util/file_util"
require "../../_util/text_util"
require "../../mtlv1/mt_core"
require "../ch_info"

module CV::Zhtext
  class Options
    include JSON::Serializable

    property encoding : String? = nil

    property init_chidx = 1_i16
    property init_chvol = ""

    property to_simp = false
    property un_wrap = false

    property split_mode = 1

    # for mode 0
    property repeating = 3

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

    def initialize
      yield self
    end
  end

  class Chapter
    property chidx = 0_i16
    property schid = ""

    property chvol = ""
    property title : String { @lines[0] }

    getter c_len = 0
    getter p_len : Int32 { content.size }
    getter content : Array(String) { split_parts }

    getter lines = [] of String
    getter sizes = [] of Int32

    def initialize(@chvol, @chidx = 0_i16, @schid = chidx.to_s)
    end

    def empty?
      @lines.empty?
    end

    def set_first_as_chvol!(new_title : String) : String
      new_size = new_title.size
      @c_len, @sizes[0] = @c_len &- @sizes[0] &+ new_size, new_size

      @chvol, lines[0] = @lines[0], new_title
      @chvol
    end

    def add_line(line : String) : Nil
      return if line.blank?
      @lines << line

      char_count = line.size
      @sizes << char_count
      @c_len &+= char_count
    end

    CHAR_LIMIT = 3000

    private def split_parts : Array(String)
      return [@lines.join('\n')] if @c_len <= CHAR_LIMIT * 1.5

      output = [] of String

      p_len = @c_len // CHAR_LIMIT &+ 1
      char_limit = @c_len // p_len

      title = @lines[0]

      buffer = String::Builder.new(title)
      char_count = @sizes[0]

      (1...@lines.size).each do |idx|
        buffer << '\n' << @lines.unsafe_fetch(idx)

        char_count &+= @sizes.unsafe_fetch(idx)
        next if char_count < char_limit

        output << buffer.to_s
        buffer = String::Builder.new(title)
        char_count = 0
      end

      output << buffer.to_s if char_count > 0
      output
    end

    def save!(base : String) : Nil
      content.each_with_index do |text, part|
        File.write("#{base}/#{@chidx}-#{part}.txt", text)
      end
    end
  end

  class Splitter
    getter inp_file : String
    getter save_dir : String

    getter raw_data : Array(String)
    getter chapters = [] of Chapter

    getter chmin : Int16
    getter chvol : String

    def initialize(@inp_file, @options = Options.new,
                   save_dir : String? = nil, content : String? = nil)
      @save_dir = save_dir || File.dirname(inp_file).sub("chaps/users", "chtexts")

      content ||= FileUtil.read_utf8(inp_file, options.encoding)
      @raw_data = format_input(content, options.un_wrap, options.to_simp)

      @chmin = options.init_chidx
      @chvol = options.init_chvol
    end

    private def format_input(input : String, un_wrap = false, to_simp = false)
      input = input.gsub(/\r\n?/, '\n')
      input = fix_linebreaks(input) if un_wrap
      input = MtCore.trad_to_simp(input) if to_simp

      output = input.split('\n')
      output[0] = output[0].tr("\uFEFF", "")
      output
    end

    def fix_linebreaks(input : String, min_invalid_chars = 10)
      title_re = /^第|[。！#\p{Pe}\p{Pf}]\s*$/

      output = String::Builder.new
      invalid = false

      input.each_line do |line|
        output << line unless line.empty?
        if (invalid || line.size > min_invalid_chars) && line !~ title_re
          invalid = true
        else
          invalid = false
          output << '\n'
        end
      end

      output.to_s
    end

    def split!(split_mode = @options.split_mode, options = @options) : self
      File.write(@inp_file.sub(".txt", ".json"), options.to_pretty_json)

      case split_mode
      when 0 then split_mode_0(options.repeating)
      when 1 then split_mode_1(options.trim_space, options.min_blanks)
      when 2 then split_mode_2(options.need_blank)
      when 3 then split_mode_3(options.title_suffix)
      when 4 then split_mode_4(options.custom_regex)
      else        raise "Chế độ chia chưa được hỗ trợ!"
      end

      self
    end

    # split by manually putting `///` between chaps
    private def split_mode_0(repeating = 3)
      delimit_re = /^\s*\/{#{repeating},}(.*)$/
      chapter = new_chapter

      @raw_data.each do |line|
        if match = line.match(delimit_re)
          add_chapter(chapter) # add orevious chapter if any
          chapter = new_chapter

          suffix = clean_spaces(match[1])
          @chvol = suffix unless suffix.empty?
        else
          chapter.add_line(clean_spaces(line))
        end
      end

      add_chapter(chapter)
    end

    # split if there is `min_blanks` number of adjacent blank lines
    private def split_mode_1(trim_space = false, min_blanks = 2)
      blank_count = 0

      split_inner do |line|
        line = clean_spaces(line) if trim_space

        if line.empty?
          blank_count &+= 1
          blank_count >= min_blanks
        else
          blank_count = 0
          false
        end
      end
    end

    # split if body is padded with spaces
    private def split_mode_2(need_blank : Bool = false)
      prev_was_blank = true

      split_inner do |line|
        if line.empty? || line =~ /^[ 　\t]/
          prev_was_blank = true
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
      raise "Lỗi nhập: Không có nhãn chương" if suffixes.empty?
      split_mode_4("^[ 　]*第[\\d零〇一二两三四五六七八九十百千]+[#{suffixes}]")
    end

    private def split_mode_4(regex_str : String)
      regex = Regex.new(regex_str)
      split_inner { |line| line =~ regex }
    end

    ###########

    private def split_inner
      chapter = new_chapter
      prev_was_chvol = false

      @raw_data.each_with_index(1) do |line, idx|
        is_new_chap = yield line # check if this is the mark of new chapter
        line = clean_spaces(line)

        if !is_new_chap
          chapter.add_line(line)
          prev_was_chvol = false
        elsif chapter.lines.size != 1
          # previous chapter do not contain just a single line
          add_chapter(chapter)
          chapter = new_chapter(line)

          prev_was_chvol = false
        elsif prev_was_chvol
          raise "Lỗi (dòng: #{idx} [#{line[0..10]}]): Chương phía trước không có nội dung."
        else
          @chvol = chapter.set_first_as_chvol!(line)
          prev_was_chvol = true
        end
      end

      add_chapter(chapter)
    end

    private def new_chapter(title : String? = nil)
      chidx = @chmin &+ @chapters.size
      Chapter.new(@chvol, chidx).tap { |x| x.add_line(title) if title }
    end

    private def add_chapter(chapter : Chapter)
      return if chapter.lines.empty?

      count = chapter.p_len
      raise "Chương số #{chapter.chidx} có quá nhiều phần (#{count})" if count > 30

      if @chapters.size > 4000
        raise "Lỗi chia: Số lượng chương quá nhiều (#{@chapters.size} chương)"
      end

      @chapters << chapter
    end

    private def clean_spaces(input : String)
      input.tr("\t\u00A0\u2002\u2003\u2004\u2007\u2008\u205F\u3000", " ").strip
    end

    def save_content!
      groups = @chapters.group_by { |x| (x.chidx &- 1) // 128 }

      groups.each do |group, chaps|
        base_path = "#{save_dir}/#{group}"
        Dir.mkdir_p(base_path)

        chaps.each(&.save!(base_path))
        message = `zip -rjmq "#{base_path}.zip" "#{base_path}"`

        raise message unless $?.success?
        Dir.delete(base_path)
      end
    end

    def save_chinfos!(mtime : Int64 = Time.utc.to_unix, uname : String = "")
      info_file = File.open("#{@save_dir}/patch.tab", "a")

      @chapters.each do |chap|
        data = {
          chap.chidx, chap.schid,
          chap.title, chap.chvol, chap.chidx,
          mtime, chap.c_len, chap.p_len, uname,
        }
        info_file << '\n'
        info_file.puts(data.join('\t'))
      end

      info_file.close
    end
  end
end
