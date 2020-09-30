require "json"

require "./cv_node"

class CvData
  getter data = [] of CvNode
  # forward_missing_to @data

  delegate :<<, to: @data
  delegate each, to: @data
  delegate last?, to: @data

  def grammarize!
    # TODO: handle more special rules, like:
    # - convert hanzi to number,
    # - convert hanzi percent
    # - date and time
    # - guess special words meaning..
    # - apply `的` grammar
    # - apply other grammar rule
    # - ...

    prev = nil

    @data.each_with_index do |node, i|
      case node.key
      when "的"
        # TODO: handle `的`
        node.dic = 9
        node.val = ""
      when "了"
        # TODO: remove "了" only if prev is a verb
        node.dic = 9
        node.val = border?(i + 1) || match_key?(i + 2, "了") ? "rồi" : ""
      when "对"
        # TODO: handle nouns?
        node.dic = 9
        node.val = border?(i + 1) || match_key?(i + 1, "的") ? "đúng" : "đối với"
      when "也"
        node.dic = 9
        node.val = border?(i + 1) ? "vậy" : "cũng"
      when "地"
        # TODO: check noun, verb?
        node.dic = 9
        node.val = border?(i - 1) ? "địa" : "mà"
      when "原来"
        node.dic = 9
        node.val = border?(i - 1) && !match_key?(i + 1, "的") ? "thì ra" : " ban đầu"

        # when "不过"
        # TODO!
      when "行"
        next unless border?(i - 1) && border?(i + 1)
        node.dic = 9
        node.val = "được"
        # when "斤"
        #   next unless prev = @data[i - 1]?
        #   next unless num = prev.to_i?
        #   val = (num / 2 * 10).round / 10
        # node.dic = 9
        # node.val = val.to_s

      when "两"
        fix_unit(node, @data[i - 1]?, "lượng")
      when "里"
        fix_unit(node, @data[i - 1]?, "dặm")
      when "米"
        fix_unit(node, @data[i - 1]?, "mét")
      when "年"
        # TODO: handle special cases for year
        next unless prev = @data[i - 1]?
        next unless prev.to_i?

        fix_date(node, prev, "năm")
      when "月"
        next unless prev = @data[i - 1]?
        next unless prev.to_i?.try(&.<= 12)

        fix_date(node, prev, "tháng")
      when "日"
        next unless prev = @data[i - 1]?
        next unless prev.to_i?.try(&.<= 31)

        fix_date(node, prev, "ngày")
      end
    end

    self
  end

  private def fix_unit(node : CvNode, prev : CvNode?, val : String)
    return unless prev && prev.number?
    node.dic = 9
    node.val = val
  end

  private def fix_date(node : CvNode, prev : CvNode, val : String)
    prev.dic = 9
    prev.key += node.key
    prev.val = "#{val} #{prev.val}"

    node.dic = 0
    node.key = ""
    node.val = ""
  end

  private def match_node?(idx : Int32)
    return false unless node = @data[idx]?
    yield node
  end

  private def border?(idx : Int32) : Bool
    !match_node?(idx, &.dic.> 0)
  end

  private def lexicon?(idx : Int32) : Bool
    match_node?(idx, &.dic.> 1)
  end

  private def match_key?(idx : Int32, key : String)
    match_node?(idx, &.key.== key)
  end

  def concat(other : self)
    @data.concat(other.data)
  end

  def capitalize!
    cap_mode = 1

    @data.each do |node|
      next if node.val.empty?

      if cap_mode > 0 && node.dic > 0
        node.capitalize!(cap_mode) if node.dic > 1
        cap_mode = 0 unless cap_mode > 1
      else
        cap_mode = get_cap_mode(node, cap_mode)
      end
    end

    self
  end

  def get_cap_mode(node : CvNode, prev_mode = 0) : Int32
    case node.val[-1]?
    when '“', '‘', '[', '{',
         ':', '!', '?', '.'
      prev_mode > 1 ? 2 : 1
    when '⟨'
      2
    when '⟩'
      0
    else
      prev_mode
    end
  end

  def pad_spaces!
    return self if @data.empty?

    acc = @data.first
    res = [acc]

    1.upto(@data.size - 1).each do |i|
      cur = @data.unsafe_fetch(i)

      unless cur.val.empty?
        res << CvNode.new("", " ", 0) if should_space?(acc, cur)
        acc = cur
      end

      res << cur
    end

    @data = res
    self
  end

  private def should_space?(left : CvNode, right : CvNode)
    return false if left.val.blank? || right.val.blank?

    # handle .jpg case
    return false if right.dic == 1 && right.key[0]? == '.'

    case right.val[0]?
    when '”', '’', '⟩', ')', ']', '}',
         ',', '.', ':', ';', '!', '?',
         '%', '~'
      return false
    when '·'
      return true
    when '…'
      case left.val[-1]?
      when '.', ','
        return true
      else
        return false
      end
    end

    case left.val[-1]?
    when '“', '‘', '⟨', '(', '[', '{'
      return false
    when '”', '’', '⟩', ')', ']', '}',
         ',', '.', ':', ';', '!', '?',
         '…', '~', '—', '·'
      return true
    end

    left.dic > 0 || right.dic > 0
  end

  def zh_text(io : IO)
    @data.each { |item| io << item.key }
  end

  def zh_text
    String.build { |io| zh_text(io) }
  end

  def vi_text(io : IO)
    @data.each { |item| io << item.val }
  end

  def vi_text
    String.build { |io| vi_text(io) }
  end

  def to_s(io : IO)
    return io if @data.empty?
    @data.unsafe_fetch(0).to_s(io)

    1.upto(@data.size - 1) do |i|
      io << '\t'
      @data.unsafe_fetch(i).to_s(io)
    end

    io
  end

  def to_s : String
    String.build { |io| to_s(io) }
  end

  # class methods

  def self.zh_text(text : String)
    String.build do |io|
      text.split(/[\tǁ]/).each do |node|
        io << node.split(CvNode::SEP_1, 2).first
      end
    end
  end
end
