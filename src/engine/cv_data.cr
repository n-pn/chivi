require "json"
require "../_utils/text_utils"

class CvData
  SEP_0 = "ǁ"
  SEP_1 = "¦"

  class Node
    property key : String
    property val : String
    property dic : Int32
    property etc : String

    def initialize(@key : String, @val : String, @dic : Int32 = 0, @etc = "")
    end

    def initialize(key : Char, val : Char, @dic : Int32 = 0, @etc = "")
      @key = key.to_s
      @val = val.to_s
    end

    def initialize(char : Char, @dic : Int32 = 0, @etc = "")
      @key = @val = char.to_s
    end

    def to_s
      String.build { |io| to_s(io) }
    end

    def to_s(io : IO)
      io << @key << SEP_1 << @val << SEP_1 << @dic
    end

    # return true if
    def capitalize!
      @val = Utils.capitalize(@val)
    end

    LETTER_RE = /[\p{L}\p{N}\p{Han}\p{Hiragana}\p{Katakana}]/

    def match_letter?
      LETTER_RE.matches?(@val)
    end

    def special_char?
      case @key[0]?
      when '_', '.', '%', '-', '/', '?', '=', ':'
        true
      else
        false
      end
    end

    def unchanged?
      @key == @val
    end

    def combine!(other : self)
      @key = other.key + @key
      @val = other.val + @val
    end

    def should_cap_after?
      case @val[-1]?
      when '“', '‘', '⟨', '[', '{', '.', ':', '!', '?', ' '
        return true
      else
        return false
      end
    end

    def should_space_before?
      # return true if @dic > 0

      case @val[0]?
      when '”', '’', '⟩', ')', ']', '}', ',', '.', ':', ';',
           '!', '?', '%', ' ', '_', '…', '/', '\\', '~'
        false
      else
        true
      end
    end

    def should_space_after?
      # return true if @dic > 0

      case @val[-1]?
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

  getter data = [] of Node
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

    each do |node|
      if node.key == "的"
        node.val = ""
        node.dic = 0
      end
    end

    self
  end

  def concat(other : self)
    @data.concat(other.data)
  end

  def capitalize!
    apply_cap = true

    each do |node|
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
    res = [] of Node
    add_space = false

    @data.each do |node|
      if node.val.empty?
        res << node
      else
        res << Node.new("", " ", 0) if add_space && node.should_space_before?
        add_space = node.should_space_after?
        res << node
      end
    end

    @data = res
    self
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
    map(&.to_s).join(SEP_0, io)
  end

  def to_s : String
    String.build { |io| to_s(io) }
  end
end
