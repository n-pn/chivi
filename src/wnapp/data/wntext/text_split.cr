require "../../../_util/text_util"

module WN::TextSplit
  extend self

  LIMIT = 3000
  UPPER = 4500

  # split text of a single chapter, returning text parts and char count
  def split_entry(input : String) : {Array(String), Int32}
    input = TextUtil.clean_spaces(input) # fix whitespaces

    c_len = input.size
    if c_len <= UPPER
      limit = c_len
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

  # split multi chapters; returning array of text parts, char count and volume name if available
  def split_multi(input : String, chdiv : String = "") : Array({Array(String), Int32, String})
    # TODO
  end
end
