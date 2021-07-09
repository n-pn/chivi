module CV::Improving
  private def boundary?(node : Nil)
    true
  end

  private def boundary?(node : MtNode)
    node.tag.puncts? || node.tag.interjection?
  end

  def fix_grammar!(node = @root)
    while node = node.succ
      case node.tag
      when .ude1? # 的
        node.update!(val: "")
      when .ule? # 了
        next unless (prev = node.prev) && (succ = node.succ)
        node.update!(val: "") if prev.tag.verbs? && !succ.tag.ends? && succ.key != prev.key
      when .ude2? # 地
        next if !boundary?(node.succ) && node.prev.try(&.tag.adjts?)
        next if !boundary?(node.prev) && node.succ.try(&.tag.verbs?)
        node.update!(val: "địa", tag: PosTag::Noun)
      when .string?
        if node.key =~ /^\d+$/
          node.update!(tag: PosTag::Number)
          fix_number!(node)
        else
          fix_string!(node)
        end
      when .number?
        fix_number!(node)
      else
        fix_by_key!(node)
      end
    end

    # fix_adjes!
    # fix_nouns!
    # combine_的!

    self
  rescue err
    self
  end

  def fix_string!(node : MtNode)
    return unless node.val.starts_with?("http")
    # TODO: handle links
  end

  QUANTI = {
    "石" => "thạch",
    "两" => "lượng",
    "里" => "dặm",
    "米" => "mét",
  }

  def fix_number!(node : MtNode)
    return unless succ = node.succ

    {% begin %}
    case succ.key
      {% for key, val in QUANTI %}
      when {{key}} then succ.update!({{val}}, PosTag::Quanti)
      {% end %}
    end
    {% end %}
  end

  private def fix_by_key!(node : MtNode)
    case node.key
    when "对"
      if node.succ.try { |x| x.real? || x.quoteop? }
        node.update!("đối với", PosTag::Verb)
      else
        node.update!("đúng", PosTag::Adjt)
      end
    when "不对"
      if node.succ.try { |x| x.real? || x.quoteop? }
        node.update!("không đối với", PosTag::Verb)
      else
        node.update!("không đúng", PosTag::Adjt)
      end
    when "也"
      if boundary?(node.succ)
        node.update!("vậy", PosTag::Interjection)
      else
        node.update!("cũng", PosTag::Adverb)
      end
    when "原来"
      if node.succ.try(&.ude1?) || node.prev.try(&.real?)
        val = "ban đầu"
      else
        val = "thì ra"
      end
      node.update!(val)
    when "行"
      node.update!("được") if boundary?(node.succ)
    when "高达"
      node.update!("cao đến") if node.succ.try(&.number?)
    end
  end

  private def fix_adjts!(node = @root)
    while node = node.succ
      next unless node.adjts?

      prev = node.prev.not_nil!
      skip, left, right = false, "", ""

      case prev.key
      when "不", "很", "太", "多", "未", "更", "级", "超"
        skip, left = true, "#{prev.val} "
      when "最", "那么", "这么", "非常",
           "很大", "如此", "极为"
        skip, right = true, " #{prev.val}"
      when "不太"
        skip, left, right = true, "không ", " lắm"
        # else
        # skip, left = true, "#{prev.val} " if prev.cat == 4
      end

      node.merge_left!(left, right) if skip
    end

    self
  end

  private def fix_nouns!(node = @root)
    while node = node.succ
      prev = node.prev.not_nil!
      if node.cat == 1
        skip, left, right = false, "", ""

        case prev.key
        when "这", "这位", "这具", "这个", "这种",
             "这些", "这样", "这段", "这份", "这帮",
             "这条"
          skip, left, right = true, suffix(prev.key[1]?), " này"
        when "那位", "那具", "那个", "那种",
             "那些", "那样", "那段", "那份", "那帮",
             "那条"
          skip, left, right = true, suffix(prev.key[1]?), " kia"
        when "那"
          # TODO: skipping if 那 is in front
          skip, left, right = true, suffix(prev.key[1]?), " kia"
        when "什么"
          skip, right = true, " cái gì"
        when "没什么"
          skip, left, right = true, "không có ", " gì"
        when "这样的"
          skip, right = true, " như vậy"
        when "哪个"
          skip, left, right = true, "cái ", " nào"
        when "其他", "其她", "其它"
          skip, left, right = true, "cái ", " khác"
        when "别的"
          skip, right = true, " khác"
        when "某个"
          skip, right = true, " nào đó"
        when "一串", "一个", "一只", "几个"
          skip, left = true, "#{prev.val} "
        when "另一个"
          skip, left, right = true, "một cái ", " khác"
        end

        case prev.cat
        when 5 # noun and adje
          skip, left = true, "#{prev.val} "
          # when 4 # only adje
          #   skip, right = true, " #{prev.val}"
        when 1 # only nown
          case node.key
          when "姐", "姐姐", "大姐", "小姐", "大小姐",
               "哥", "哥哥", "大哥", "先生", "小姐姐",
               "小队", "老师", "身上", "大人"
            skip, left = true, "#{prev.val} "
          else
            if prev.person?
              skip, left = true, "#{prev.val} "
            end
          end
        end

        node.merge_left!(left, right) if skip
      end
    end

    self
  end

  private def suffix(char : Char?)
    case char
    when '位' then "vị "
    when '具' then "cụ "
    when '个' then "cái "
    when '种' then "loại "
    when '些' then "những "
    when '样' then "dạng "
    when '段' then "đoạn "
    when '份' then "phần "
    when '帮' then "đám "
    when '条' then "điều "
    else          ""
    end
  end

  private def combine_的!
    res = MtNode.new("")
    idx = 0

    while idx < @data.size
      curr = @data.unsafe_fetch(idx)

      if curr.key == "的" && (left = res.last?)
        if right = @data[idx + 1]?
          if right.noun? && !res[-2]?.try(&.verb?)
            skip = false
            if left.adje?
              left.val = "#{right.val} #{left.val}"
              skip = true
            elsif left.cat == 1
              left.val = "#{right.val} của #{left.val}"
              skip = true
            end

            if skip
              left.key = "#{left.key}的#{right.key}"
              left.dic = 9
              left.cat |= 1

              idx += 2
              next
            end
          end
        elsif left.pronoun? && !res[-2]?.try(&.verb?)
          left.key = "#{left.key}的"
          left.val = "của #{left.val}"
          left.cat |= 1
          left.dic = 9
          idx += 1
          next
        end
      end

      res << curr
      idx += 1
    end

    @data = res
  end
end
