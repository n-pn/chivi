require "json"
require "./cv_node"
require "../../utils/text_utils"

module CvUtil
  extend self

  def cap_after?(val : String)
    case val[-1]
    when '“', '‘', '⟨', '[', '{', '.', ':', '!', '?'
      return true
    else
      return false
    end
  end

  def space_before?(char : Char)
    case char
    when '”', '’', '⟩', ')', ']', '}', ',', '.', ':', ';',
         '!', '?', '%', ' ', '_', '…', '/', '\\', '~'
      false
    else
      true
    end
  end

  def space_after?(char : Char)
    case char
    # when '”', '’', '⟩', ')', ']', '}', ',', '.', ':', ';',
    #      '!', '?', '%', '…', '~', '—'
    #   true
    # else
    #   false
    when '“', '‘', '⟨', '(', '[', '{', ' ', '_', '/', '\\'
      false
    else
      true
    end
  end
end

class CvData < Array(CvNode)
  SEP = "ǁ"

  def grammarize!
    # TODO: handle more special rules, like:
    # - convert hanzi to number,
    # - convert hanzi percent
    # - date and time
    # - guess special words meaning..
    # - apply `的` grammar
    # - apply other grammar rule
    # - ...

    each do |node|
      if node.key == "的"
        node.val = ""
        node.dic = 0
      end
    end

    self
  end

  def capitalize!(apply_cap : Bool = true)
    each do |node|
      next if node.val.empty?

      if apply_cap && node.val =~ /[\p{L}\p{N}]/
        node.val = Utils.capitalize(node.val)
        apply_cap = false
      else
        apply_cap ||= CvUtil.cap_after?(node.val)
      end
    end

    self
  end

  def pad_spaces!
    add_space = false
    nodes = CvData.new

    each do |node|
      if node.val.empty?
        nodes << node
      else
        if add_space && (node.dic > 0 || CvUtil.space_before?(node.val[0]))
          nodes << CvNode.new("", " ", 0)
        end

        add_space = node.dic > 0 || CvUtil.space_after?(node.val[-1])
        nodes << node
      end
    end

    nodes
  end

  def zh_text(io : IO)
    each { |item| io << item.key }
  end

  def zh_text
    String.build { |io| zh_text(io) }
  end

  def vi_text(io : IO)
    each { |item| io << item.val }
  end

  def vi_text
    String.build { |io| vi_text(io) }
  end

  def to_s(io : IO) : Void
    map(&.to_s).join(SEP, io)
  end

  def to_s : String
    String.build { |io| to_s(io) }
  end
end
