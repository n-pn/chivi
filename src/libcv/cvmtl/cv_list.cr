require "./cv_node"
require "./cv_list/*"

class CV::CvList
  alias Input = Deque(CvNode)

  getter root = CvNode.new("", "")

  def first?
    @root.succ
  end

  def merge!(list : self, node = @root)
    while node = node.succ
      unless node.succ
        node.set_succ(list.root)
        return self
      end
    end

    self
  end

  def prepend!(node : CvNode)
    @root.set_succ(node)
  end

  def fix_grammar!(node = @root)
    while node = node.succ
      case node.key
      when "的"
        node.fix(val: "", cat: 0)
      when "了"
        node.fix(val: "rồi", cat: 0)

        if (prev = node.prev) && (prev.verb? || prev.cat == 0)
          next unless succ = node.succ
          node.fix("") if succ.word? && succ.key != prev.key
        end
      when "对"
        if node.succ.try { |x| x.cat > 0 || x.key[0] == '“' }
          node.fix("đối với")
        else
          node.fix("đúng")
        end
      when "不对"
        if node.succ.try { |x| x.cat > 0 || x.key[0] == '“' }
          node.fix("không đối với")
        else
          node.fix("không đúng")
        end
      when "也"
        node.fix(node.succ.try(&.word?) ? "cũng" : "vậy")
      when "地"
        # TODO: check noun, verb?
        if prev = node.prev
          val = prev.adje? || prev.key[-1]? == '”' ? "mà" : "địa"
          node.fix(val)
        end
      when "原来"
        if node.succ.try(&.match_key?("的")) || node.prev.try(&.word?)
          val = "ban đầu"
        else
          val = "thì ra"
        end
        node.fix(val)
      when "行"
        node.fix("được") unless node.succ.try(&.dic.> 0)
      when "高达"
        node.fix("cao đến") if node.succ.try(&.is_num)
      when "石"
        node.fix("thạch") if node.prev!.is_num
      when "两"
        node.fix("lượng") if node.prev!.is_num
      when "里"
        node.fix("dặm") if node.prev!.is_num
      when "米"
        node.fix("mét") if node.prev!.is_num
      when "年"
        # TODO: handle special cases for year
        next unless prev = node.prev
        next unless prev.to_i?.try(&.>= 100)

        node.key = "#{prev.key}#{node.key}"
        node.fix("năm #{prev.key}")

        prev.clear!
      when "月"
        next unless prev = node.prev
        next unless prev.to_i?.try(&.<= 15)

        node.key = "#{prev.key}#{node.key}"
        node.fix("tháng #{prev.key}")

        prev.clear!
      when "日"
        next unless prev = node.prev
        next unless prev.to_i?.try(&.<= 40)

        node.key = "#{prev.key}#{node.key}"
        node.fix("ngày #{prev.key}")

        prev.clear!
      end
    end

    fix_adjes!
    fix_nouns!
    # combine_的!

    self
  rescue err
    self
  end

  private def fix_adjes!(node = @root)
    while node = node.succ
      if node.adje?
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
        else
          skip, left = true, "#{prev.val} " if prev.cat == 4
        end

        if skip
          prev.key = "#{prev.key}#{node.key}"
          prev.val = "#{left}#{node.val}#{right}"

          prev.cat |= 4
          prev.dic = node.dic if prev.dic < node.dic

          next
        end
      end
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

        if skip
          prev.key = "#{prev.key}#{node.key}"
          prev.val = "#{left}#{node.val}#{right}"

          prev.cat = 1
          prev.dic = node.dic if prev.dic < node.dic

          next
        end
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
    res = Input.new
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

  def capitalize!(node = @root, cap_mode = 1) : self
    while node = node.succ
      next unless char = node.val[-1]?

      if cap_mode > 0 && node.dic > 0
        node.capitalize!(cap_mode) if node.dic > 1
        cap_mode = cap_mode == 2 ? 2 : 0
      else
        cap_mode = Capitalization.cap_mode(char, cap_mode)
      end
    end

    self
  end

  def pad_spaces!(node = @root) : self
    return self unless node = node.succ
    prev = node

    while node = node.succ
      node.set_prev(CvNode.new("", " ")) if PadSpaces.space?(prev, node)
      prev = node unless node.val.empty?
    end

    self
  end

  def to_s : String
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO) : Nil
    each { |node| io << node.val }
  end

  def each(node = @root)
    while node = node.succ
      yield node
    end
  end

  def to_str : String
    String.build { |io| to_str(io) }
  end

  def to_str(io : IO) : Nil
    return unless node = @root.succ
    node.to_str(io)

    while node = node.succ
      io << '\t'
      node.to_str(io)
    end
  end

  def inspect(io : IO) : Nil
    return unless node = @root.succ
    node.inspect(io)

    while node = node.succ
      io << ' '
      node.inspect(io)
    end
  end
end
