require "./cv_entry"

class Chivi::CvGroup
  getter data : Array(CvEntry)

  def initialize(@data = [] of CvEntry)
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
        entry.dic = 9

        # TODO: handle `的`
        entry.val = ""
      when "了"
        entry.dic = 9

        # TODO: remove "了" only if prev is a verb
        succ = @data[i + 1]?
        if succ && succ.dic > 0 && succ.key != @data[i - 1]?.try(&.key)
          entry.val = ""
        else
          entry.val = "rồi"
        end
      when "对"
        entry.dic = 9

        # TODO: handle succ type?
        succ = @data[i + 1]?
        if succ && succ.dic > 0 && succ.key != "的"
          entry.val = "đối với"
        else
          entry.val = "đúng"
        end
        # when "不过"
        # TODO!
      when "也"
        entry.dic = 9
        entry.val = @data[i + 1]?.try(&.dic.> 0) ? "cũng" : "vậy"
      when "地"
        entry.dic = 9
        # TODO: check noun, verb?
        entry.val = @data[i - 1]?.try(&.dic.> 0) ? "mà" : "địa"
      when "原来"
        entry.dic = 9

        if @data[i + 1]?.try(&.key.== "的") || @data[i - 1].try(&.dic.> 1)
          entry.val = "ban đầu"
        else
          entry.val = "thì ra"
        end
      when "行"
        next unless @data[i + 1].try(&.dic.> 0)
        entry.dic = 9
        entry.val = "được"

        # when "斤"
        #   next unless prev = @data[i - 1]?
        #   next unless num = prev.to_i?
        #   val = (num / 2 * 10).round / 10
        # entry.dic = 9
        # entry.val = val.to_s

      when "两"
        next unless @data[i - 1]?.try(&.number?)
        entry.dic = 9
        entry.val = "lượng"
      when "里"
        next unless @data[i - 1]?.try(&.number?)
        entry.dic = 9
        entry.val = "dặm"
      when "米"
        next unless @data[i - 1]?.try(&.number?)
        entry.dic = 9
        entry.val = "mét"
      when "年"
        # TODO: handle special cases for year
        next unless prev = @data[i - 1]?
        next unless prev.to_i?.try(&.>= 100)

        entry.dic = 9
        entry.key = "#{prev.key}#{entry.key}"
        entry.val = "năm #{prev.key}"
        prev.clear!
      when "月"
        next unless prev = @data[i - 1]?
        next unless prev.to_i?.try(&.<= 15)

        entry.dic = 9
        entry.key = "#{prev.key}#{entry.key}"
        entry.val = "tháng #{prev.key}"
        prev.clear!
      when "日"
        next unless prev = @data[i - 1]?
        next unless prev.to_i?.try(&.<= 40)

        entry.dic = 9
        entry.key = "#{prev.key}#{entry.key}"
        entry.val = "ngày #{prev.key}"
        prev.clear!
      end
    end

    self
  end

  def capitalize! : self
    cap_mode = 1

    @data.each do |entry|
      next if entry.val.empty?

      if cap_mode > 0 && entry.dic > 0
        entry.capitalize!(cap_mode) if entry.dic > 1
        cap_mode = 0 unless cap_mode > 1
      else
        cap_mode = entry.cap_mode
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
        temp << CvEntry.new("", " ", 0) if curr.space_before?(prev)
        prev = curr
      end

      temp << curr
    end

    @data = temp
    self
  end

  def to_text : String
    String.build { |io| to_text(io) }
  end

  def to_text(io : IO) : Nil
    @data.each { |x| io << x.val }
  end

  def to_json(io : IO)
    @data.map { |x| {x.key, x.val, x.dic}.join('\t') }.join(io, '\v')
  end
end
