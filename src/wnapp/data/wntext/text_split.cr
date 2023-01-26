require "../../../_util/text_util"

module WN::TextSplit
  extend self

  # split multi chapters; returning array of text parts, char count and volume name if available
  def split_multi(input : String, cleaned : Bool = false) : Array({String, String})
    input = TextUtil.clean_spaces(input) unless cleaned

    chaps = [] of {String, String}
    chdiv = ""

    strio = String::Builder.new
    dirty = false

    input.each_line do |line|
      if line =~ /^\/{3,}(.*)/
        chaps << {strio.to_s, chdiv} if dirty
        chdiv = $1.strip

        strio = String::Builder.new
        dirty = false
      else
        strio << '\n' if dirty
        strio << line
        dirty = true
      end
    end

    chaps << {strio.to_s, chdiv} if dirty

    chaps
  end

  LIMIT = 3000
  UPPER = 4500

  # split text of a single chapter, returning text parts and char count
  def split_entry(input : String, cleaned : Bool = false) : {Array(String), Int32}
    # fix whitespaces
    input = TextUtil.clean_spaces(input) unless cleaned

    c_len = input.size
    if c_len <= UPPER
      limit = UPPER
    else
      p_len = c_len <= UPPER ? 1 : ((c_len - 1) // LIMIT) + 1
      limit = c_len // p_len
    end

    lines = input.each_line
    title = lines.next.as(String).strip # extract first line as title

    parts = [title]
    strio = String::Builder.new
    count = 0

    lines.each do |line|
      line = line.strip
      next if line.empty?

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

# WN::TextSplit.split_batch(text).each do |chap|
#   pp chap
# end
