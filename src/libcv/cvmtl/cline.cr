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

    handle_adjes!
    handle_nouns!

    res = [] of Cword
    i = 0

    while i < @data.size
      curr = @data.unsafe_fetch(i)
      i += 1

      case curr.key
      when "了"
        curr.fix("rồi")

        if (prev = @data[i - 2]?) && prev.verb?
          next unless succ = @data[i]?
          curr.fix("") if succ.word? && succ.key != prev.key
        end
      when "对"
        curr.fix(@data[i]?.try(&.word?) ? "đối với" : "đúng")
      when "不对"
        curr.fix(@data[i]?.try(&.word?) ? "không đối với" : "không đúng")
      when "也"
        curr.fix(@data[i]?.try(&.word?) ? "cũng" : "vậy")
      when "地"
        # TODO: check noun, verb?
        curr.fix(@data[i - 2]?.try(&.word?) ? "mà" : "địa")
      when "原来"
        if @data[i]?.try(&.match_key?("的")) || @data[i - 2]?.try(&.word?)
          val = "ban đầu"
        else
          val = "thì ra"
        end
        curr.fix(val)
      when "行"
        curr.fix("được") unless @data[i]?.try(&.word?)
      when "高达"
        curr.fix("cao đến") if @data[i]?.try(&.is_num)
      when "两"
        curr.fix("lượng") if @data[i - 2]?.try(&.is_num)
      when "里"
        curr.fix("dặm") if @data[i - 2]?.try(&.is_num)
      when "米"
        curr.fix("mét") if @data[i - 2]?.try(&.is_num)
      when "年"
        # TODO: handle special cases for year
        next unless prev = @data[i - 2]?
        next unless prev.to_i?.try(&.>= 100)

        curr.key = "#{prev.key}#{curr.key}"
        curr.fix("năm #{prev.key}")

        prev.clear!
      when "月"
        next unless prev = @data[i - 2]?
        next unless prev.to_i?.try(&.<= 15)

        curr.key = "#{prev.key}#{curr.key}"
        curr.fix("tháng #{prev.key}")

        prev.clear!
      when "日"
        next unless prev = @data[i - 2]?
        next unless prev.to_i?.try(&.<= 40)

        curr.key = "#{prev.key}#{curr.key}"
        curr.fix("ngày #{prev.key}")

        prev.clear!
      end
    end

    combine_的!
    self
  end

  private def handle_adjes!
    res = [] of Cword
    idx = 0
    prev = nil

    @data.each do |curr|
      if prev && curr.adje?
        case prev.key
        when "不", "很", "太", "非常", "不太", "多"
          prev.key = "#{prev.key}#{curr.key}"
          prev.val = "#{prev.val} #{curr.val}"
          prev.cat |= 4
          prev.dic = curr.dic
          next
        when "那么", "这么"
          prev.key = "#{prev.key}#{curr.key}"
          prev.val = "#{curr.val} #{prev.val}"
          prev.cat |= 4
          prev.dic = curr.dic
          next
        end
      end

      prev = curr
      res << curr
    end

    @data = res
  end

  private def handle_nouns!
    res = [] of Cword
    idx = 0
    prev = nil

    @data.each do |curr|
      if prev && curr.cat == 1
        case prev.key
        when "这", "那", "这位", "那位", "这具", "那具"
          prev.key = "#{prev.key}#{curr.key}"

          right = prev.key[0] == '这' ? " này" : " kia"
          left =
            case prev.key[1]?
            when '位' then "vị "
            when '具' then "cụ "
            else          ""
            end

          prev.val = "#{left}#{curr.val}#{right}"

          prev.cat |= 1
          prev.dic = curr.dic
          next
        when "什么"
          prev.key = "#{prev.key}#{curr.key}"

          left, right = prev.val.split(" ", 2)
          prev.val = "#{left} #{curr.val} #{right}"

          prev.cat |= 1
          prev.dic = curr.dic
          next
        end
      end

      prev = curr
      res << curr
    end

    @data = res
  end

  private def combine_的!
    res = [] of Cword
    idx = 0

    while idx < @data.size
      curr = @data.unsafe_fetch(idx)

      if curr.key == "的"
        if (left = res.last?)
          if right = @data[idx + 1]?
            if right.noun?
              skip = false
              if left.adje?
                left.key = "#{left.key}的#{right.key}"
                left.val = "#{right.val} #{left.val}"
                skip = true
                # elsif left.pronoun?
                #   left.key = "#{left.key}的#{right.key}"
                #   left.val = "#{right.val} của #{left.val}"
                #   skip = true
              end

              if skip
                left.dic = 9
                left.cat ^= 1

                idx += 2
                next
              end
            end
          elsif left.pronoun?
            left.key = "#{left.key}的"
            left.val = "của #{left.val}"

            left.dic = 9
            idx += 1
            next
          end
        end

        curr.fix("")
      end

      res << curr
      idx += 1
    end

    @data = res
  end

  def capitalize! : self
    cap_mode = 1

    @data.each do |entry|
      next if entry.val.empty?

      if cap_mode > 0 && entry.dic > 0
        entry.capitalize!(cap_mode) if entry.dic > 1
        cap_mode = 0 unless cap_mode > 1
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
