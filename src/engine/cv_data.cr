require "json"
require "../common/text_util"

require "./cv_node"

class CvData
  getter data = [] of CvNode
  # forward_missing_to @data

  delegate :<<, to: @data
  delegate each, to: @data

  def grammarize!
    # TODO: handle more special rules, like:
    # - convert hanzi to number,
    # - convert hanzi percent
    # - date and time
    # - guess special words meaning..
    # - apply `的` grammar
    # - apply other grammar rule
    # - ...

    @data.each_with_index do |node, idx|
      case node.key
      when "了"
        if match_node?(idx + 1, &.dic.>(0)) && match_node?(idx + 2, &.key.!=("了"))
          node.val = ""
          node.dic = 1
        end
      when "对"
        unless match_node?(idx + 1, &.dic.>(0))
          node.val = "đúng"
        end
      when "的"
        node.val = ""
        node.dic = 1
      end
    end

    self
  end

  private def match_node?(idx : Int32)
    return false unless node = @data[idx]?
    yield node
  end

  def concat(other : self)
    @data.concat(other.data)
  end

  def capitalize!
    apply_cap = true

    @data.each do |node|
      next if node.val.empty?

      if apply_cap && node.match_letter?
        node.capitalize!
        apply_cap = false
      else
        apply_cap ||= node.should_cap_after?
      end
    end

    self
  end

  def pad_spaces!
    res = [] of CvNode
    add_space = false

    @data.each do |node|
      if node.val.empty?
        res << node
      else
        res << CvNode.new("", " ", 0) if add_space && node.should_space_before?
        add_space = node.should_space_after?
        res << node
      end
    end

    @data = res
    self
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
