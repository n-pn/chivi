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

    @data.each_with_index do |node, i|
      case node.key
      when "+", "-", "^"
        node.val = " " + node.val if lexicon?(i - 1)
        node.val += " " if lexicon?(i + 1)
      when "年", "月", "日"
        next unless prev = @data[i - 1]?
        next unless prev.dic == 1 && prev.key =~ /^\d+$/

        prev.key += node.key
        prev.val = "#{cv_key(node.key)} #{prev.val}"

        node.key = ""
        node.val = ""
        node.dic = 9
      when "两"
        next unless prev = @data[i - 1]?
        next unless prev.dic == 1 && prev.key =~ /^\d+$/

        node.val = "lượng"
        node.dic = 9
      when "了"
        if border?(i + 1) || match_key?(i - 2, "了") || match_key?(i + 2, "了")
          node.val = "rồi"
        else
          node.val = ""
        end
        node.dic = 9
      when "对"
        if border?(i + 1) || match_key?(i + 1, "的")
          node.val = "đúng"
        else
          node.val = "đối với"
        end

        node.dic = 9
      when "也"
        if border?(i + 1)
          node.val = "vậy"
        else
          node.val = "cũng"
        end

        node.dic = 9
      when "地"
        if border?(i - 1)
          node.val = "địa"
        else
          # TODO: check noun, verb?
          node.val = "mà"
        end

        node.dic = 9
      when "原来"
        if border?(i - 1) && !match_key?(i + 1, "的")
          node.val = "thì ra"
        else
          node.val = "ban đầu"
        end

        node.dic = 9
        # when "不过"
        # TODO!
      when "的"
        node.val = ""
        node.dic = 9
      end
    end

    self
  end

  private def cv_key(key : String)
    case key
    when "年" then "năm"
    when "月" then "tháng"
    when "日" then "ngày"
    else
      raise "unknown key #{key}"
    end
  end

  private def match_node?(idx : Int32)
    return false unless node = @data[idx]?
    yield node
  end

  private def border?(idx : Int32)
    match_node?(idx) { |x| x.dic == 0 }
  end

  private def lexicon?(idx : Int32)
    match_node?(idx) { |x| x.dic > 1 }
  end

  private def match_key?(idx : Int32, key : String)
    match_node?(idx) { |x| x.key == key }
  end

  def concat(other : self)
    @data.concat(other.data)
  end

  def capitalize!
    apply_cap = true

    @data.each do |node|
      next if node.val.empty?

      if apply_cap && node.dic > 0
        node.capitalize! if node.dic > 1
        apply_cap = false
      else
        apply_cap ||= should_cap_after?(node)
      end
    end

    self
  end

  def should_cap_after?(node : CvNode)
    case node.val[-1]?
    when '“', '‘', '⟨', '[', '{',
         ':', '!', '?', '.'
      return true
    else
      return false
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
      io << CvNode::SEP_0
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
      text.split(CvNode::SEP_0).each do |node|
        io << node.split(CvNode::SEP_1, 2).first
      end
    end
  end
end
