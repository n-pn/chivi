require "./cword"

class CV::Cline
  SEP = 'ǀ'

  getter data : Array(Cword)

  def initialize(@data)
  end

  def fix_grammar!
    # TODO: handle more special rules, like:
    # - convert hanzi to number,
    # - convert hanzi percent
    # - date and time
    # - guess special words meaning..
    # - apply `的` grammar
    # - apply other grammar rule
    # - ...

    @data.each_with_index do |curr, i|
      case curr.key
      when "那么"
        next unless succ = @data[i + 1]?
        next unless succ.adjv?

        succ.key = "#{curr.key}#{succ.key}"
        succ.val = "#{succ.val} như vậy"
        curr.clear!
      when "的"
        curr.fix("")
      when "了"
        succ = @data[i + 1]?

        if succ && succ.word? && succ.key != @data[i - 1]?.try(&.key)
          val = ""
        else
          val = "rồi"
        end

        curr.fix(val)
      when "对"
        curr.fix(@data[i + 1]?.try(&.word?) ? "đối với" : "đúng")
      when "不对"
        curr.fix(@data[i + 1]?.try(&.word?) ? "không đối với" : "không đúng")
      when "也"
        curr.fix(@data[i + 1]?.try(&.word?) ? "cũng" : "vậy")
      when "地"
        # TODO: check noun, verb?
        curr.fix(@data[i - 1]?.try(&.word?) ? "mà" : "địa")
      when "原来"
        if @data[i + 1]?.try(&.match_key?("的")) || @data[i - 1]?.try(&.word?)
          val = "ban đầu"
        else
          val = "thì ra"
        end
        curr.fix(val)
      when "高达"
        curr.fix("cao đến") if @data[i + 1]?.try(&.is_num)
      when "行"
        curr.fix("được") unless @data[i + 1]?.try(&.word?)
        # when "斤"
        #   next unless prev = @data[i - 1]?
        #   next unless num = prev.to_i?
        #   val = (num / 2 * 10).round / 10
        # curr.dic = 9
        # curr.val = val.to_s

      when "两"
        curr.fix("lượng") if @data[i - 1]?.try(&.is_num)
      when "里"
        curr.fix("dặm") if @data[i - 1]?.try(&.is_num)
      when "米"
        curr.fix("mét") if @data[i - 1]?.try(&.is_num)
      when "年"
        # TODO: handle special cases for year
        next unless prev = @data[i - 1]?
        next unless prev.to_i?.try(&.>= 100)

        curr.key = "#{prev.key}#{curr.key}"
        curr.fix("năm #{prev.key}")

        prev.clear!
      when "月"
        next unless prev = @data[i - 1]?
        next unless prev.to_i?.try(&.<= 15)

        curr.key = "#{prev.key}#{curr.key}"
        curr.fix("tháng #{prev.key}")

        prev.clear!
      when "日"
        next unless prev = @data[i - 1]?
        next unless prev.to_i?.try(&.<= 40)

        curr.key = "#{prev.key}#{curr.key}"
        curr.fix("ngày #{prev.key}")

        prev.clear!
      end
    end

    self
  end

  def capitalize! : self
    cap_mode = 1_i8

    @data.each do |entry|
      next if entry.val.empty?

      if cap_mode > 0 && entry.dic > 0
        entry.capitalize!(cap_mode) if entry.dic > 1
        cap_mode = 0_i8 unless cap_mode > 1
      else
        cap_mode = entry.cap_mode(cap_mode)
      end
    end

    self
  end

  def pad_spaces! : self
    return self if @data.empty?

    prev = @data.first
    temp = [prev]

    1.upto(@data.size - 1).each do |i|
      curr = @data.unsafe_fetch(i)

      unless curr.val.empty?
        temp << Cword.new("", " ") if curr.space_before?(prev)
        prev = curr
      end

      temp << curr
    end

    @data = temp
    self
  end

  def to_s : String
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO) : Nil
    @data.each { |x| io << x.val }
  end

  def to_str : String
    String.build { |io| to_str(io) }
  end

  def to_str(io : IO) : Nil
    @data.map { |x| {x.key, x.val, x.dic}.join(SEP) }.join(io, '\t')
  end

  def inspect(io : IO) : Nil
    @data.map do |x|
      x.key.empty? ? x.val : "[#{x.key}¦#{x.val}¦#{x.dic}]"
    end.join(io, " ")
  end
end
