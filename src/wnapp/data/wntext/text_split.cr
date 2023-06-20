require "../../../_util/text_util"

module WN::TextSplit
  extend self

  record Entry, lines : Array(String), chdiv : String

  # split multi chapters; returning array of text parts, char count and volume name if available
  def split_multi(input : String, chdiv : String = "", cleaned : Bool = false) : Array(Entry)
    input = TextUtil.clean_spaces(input) unless cleaned
    chaps = [] of Entry

    lines = [] of String

    input.each_line do |line|
      if !line.empty?
        lines << line
      elsif lines.size == 1
        chdiv = lines.first
        lines.clear
      elsif lines.empty?
        raise "invalid format!"
      else
        chaps << Entry.new(lines, chdiv)
        lines = [] of String
      end
    end

    chaps << Entry.new(lines, chdiv) unless lines.empty?

    chaps
  end

  LIMIT = 3000
  UPPER = 4500

  def get_p_len(c_len : Int32)
    c_len <= UPPER ? 1 : (c_len &- 1) // LIMIT &+ 1
  end

  # def split_entry(input : String, cleaned : Bool = false) : {Array(String), Int32}
  #   # fix whitespaces
  #   input = TextUtil.clean_spaces(input) unless cleaned
  #   lines = input.split(/\n/, remove_empty: true)
  #   split_entry(lines.shift, lines)
  # end

  # # split text of a single chapter, returning text parts and char count
  def split_entry(lines : Array(String))
    c_len = lines.sum(&.size) &+ lines.size &- 1

    if c_len <= UPPER
      limit = UPPER
    else
      p_len = (c_len &- 1) // LIMIT &+ 1
      limit = c_len // p_len
    end

    line_iter = lines.each
    parts = [line_iter.next.as(String)]

    strio = String::Builder.new
    count = 0

    line_iter.each do |line|
      strio << '\n' if count > 0
      strio << line

      count &+= line.size
      next if count < limit

      parts << strio.to_s
      strio = String::Builder.new
      count = 0
    end

    parts << strio.to_s if count > 0
    {parts, c_len}
  end
end

# text = <<-TXT
# /// tap 1
# chương 1
# nội dung chương 1

# ///
# chương 2
# nội dung chương 2

# /// tên tập
# chương 3
# TXT
