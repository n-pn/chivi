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
      when "行"
        if border?(i - 1) && border?(i + 1)
          node.val = "được"
          node.dic = 9
        end
      when "的"
        node.val = ""
        node.dic = 9
      else
        next unless node.dic == 1 && node.key =~ /^\d+$/
        next unless succ = @data[i + 1]?

        case succ.key
        when "米"
          succ.val = "mét"
          succ.dic = 9
        when "里"
          succ.val = "dặm"
          succ.dic = 9
        when "两"
          succ.val = "lượng"
          succ.dic = 9
        when "年", "月", "日"
          # TODO: handle special cases
          node.key += succ.key
          node.val = "#{cv_key(succ.key)} #{node.val}"
          node.dic = 9

          succ.key = ""
          succ.val = ""
          succ.dic = 0
        end
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
