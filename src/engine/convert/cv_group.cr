require "./cv_entry"

class CV::CvGroup
  SEP = 'ǀ'

  getter data : Array(CvEntry)

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

    prev = nil

    @data.each_with_index do |entry, i|
      case entry.key
      when "的"
        # TODO: handle `的`
        entry.fix("")
      when "了"
        succ = @data[i + 1]?

        # TODO: remove "了" only if prev is a verb
        if succ && succ.word? && succ.key != @data[i - 1]?.try(&.key)
          val = ""
        else
          val = "rồi"
        end

        entry.fix(val)
      when "对"
        entry.fix(@data[i + 1]?.try(&.noun?) ? "đối với" : "đúng")
      when "不对"
        entry.fix(@data[i + 1]?.try(&.noun?) ? "không đối với" : "không đúng")
      when "也"
        entry.fix(@data[i + 1]?.try(&.word?) ? "cũng" : "vậy")
      when "地"
        # TODO: check noun, verb?
        entry.fix(@data[i - 1]?.try(&.word?) ? "mà" : "địa")
      when "原来"
        if @data[i + 1]?.try(&.match_key?("的")) || @data[i - 1]?.try(&.word?)
          val = "ban đầu"
        else
          val = "thì ra"
        end
        entry.fix(val)
      when "高达"
        entry.fix("cao đến") if @data[i + 1]?.try(&.is_num)
      when "行"
        entry.fix("được") unless @data[i + 1]?.try(&.word?)
        # when "斤"
        #   next unless prev = @data[i - 1]?
        #   next unless num = prev.to_i?
        #   val = (num / 2 * 10).round / 10
        # entry.dic = 9
        # entry.val = val.to_s

      when "两"
        entry.fix("lượng") if @data[i - 1]?.try(&.is_num)
      when "里"
        entry.fix("dặm") if @data[i - 1]?.try(&.is_num)
      when "米"
        entry.fix("mét") if @data[i - 1]?.try(&.is_num)
      when "年"
        # TODO: handle special cases for year
        next unless prev = @data[i - 1]?
        next unless prev.to_i?.try(&.>= 100)

        entry.key = "#{prev.key}#{entry.key}"
        entry.fix("năm #{prev.key}")

        prev.clear!
      when "月"
        next unless prev = @data[i - 1]?
        next unless prev.to_i?.try(&.<= 15)

        entry.key = "#{prev.key}#{entry.key}"
        entry.fix("tháng #{prev.key}")

        prev.clear!
      when "日"
        next unless prev = @data[i - 1]?
        next unless prev.to_i?.try(&.<= 40)

        entry.key = "#{prev.key}#{entry.key}"
        entry.fix("ngày #{prev.key}")

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
        temp << CvEntry.new("", " ") if curr.space_before?(prev)
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
