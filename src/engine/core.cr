require "./dict"
require "./util"

require "json"

# require "./core/*"

class Engine::Core
  # extend self

  alias Dicts = Array(Dict)
  alias Chars = Array(Char)

  class Token
    include JSON::Serializable

    property key : String
    property val : String
    property dic : Int32 = 0

    def initialize(@key : String, @val : String, @dic = 0)
    end

    def initialize(key : Char, val : Char, @dic = 0)
      @key = key.to_s
      @val = val.to_s
    end

    def initialize(chr : Char, @dic = 0)
      @key = chr.to_s
      @val = chr.to_s
    end

    def to_s(io : IO)
      io << "[" << @key << "/" << @val << "/" << @dic << "]"
    end
  end

  getter tokens = [] of Token

  def initialize(@dicts : Array(Dict))
  end

  NUMBER     = "零〇一二三四五六七八九十百千"
  TITLE_RE_0 = /^(第?([\d#{NUMBER}]+)([集卷]))([,.:]?\s*)(.*)$/
  TITLE_RE_1 = /^(.*?)(\s*)(第?([\d#{NUMBER}]+)([章节幕回]))([,.:]?\s*)(.*)$/
  TITLE_RE_2 = /^([\d#{NUMBER}]+)([,.:]?\s*)(.*)$/

  def parse_title(input : String)
    @tokens = [] of Token

    if match = TITLE_RE_0.match(input)
      _, zh_group, index, label, trash, title = match
      vi_group = "#{vi_label(label)} #{Util.hanzi_int(index)}"

      @tokens << Token.new(zh_group, vi_group, 0)

      if title.empty?
        @tokens << Token.new(trash, "", 0) unless trash.empty?
      else
        @tokens << Token.new(trash, ":", 0) unless trash.empty?
      end

      input = title
    end

    if match = TITLE_RE_1.match(input)
      _, pre_text, pre_trash, zh_group, index, label, trash, title = match

      if pre_text.empty?
        @tokens << Token.new(pre_trash, "", 0) unless pre_trash.empty?
      else
        @tokens.concat tokenize(pre_text.chars)
        @tokens << Token.new(pre_trash, " - ", 0) unless pre_trash.empty?
      end

      vi_group = "#{vi_label(label)} #{Util.hanzi_int(index)}"
      @tokens << Token.new(zh_group, vi_group, 0)
    elsif match = TITLE_RE_2.match(input)
      _, zh_index, trash, title = match
      vi_index = "Chương #{Util.hanzi_int(zh_index)}"

      @tokens << Token.new(zh_index, vi_index, 0)
    else
      title = input
      trash = ""
    end

    if title.empty?
      @tokens << Token.new(trash, "", 0) unless trash.empty?
    else
      @tokens << Token.new(trash, ":", 0) unless trash.empty?
      @tokens.concat tokenize(title.chars)
    end

    self
  end

  private def vi_label(label : String)
    case label
    when "章" then "Chương"
    when "卷" then "Quyển"
    when "集" then "Tập"
    when "节" then "Tiết"
    when "幕" then "Màn"
    when "回" then "Hồi"
    else          label
    end
  end

  def parse_plain(input : String)
    @tokens = tokenize(input.chars)
    self
  end

  def tokenize(input : Array(Char))
    selects = [Token.new("", "")]
    weights = [0.0]

    chars = Util.normalize(input)

    input.each_with_index do |char, idx|
      selects << Token.new(char, chars[idx])
      weights << idx + 1.0
    end

    dsize = @dicts.size + 1

    chars.each_with_index do |char, i|
      choices = {} of Int32 => Tuple(Dict::Item, Int32)

      @dicts.each_with_index do |dict, j|
        dict.scan(chars, i).each do |item|
          choices[item.key.size] = {item, j + 1}
        end
      end

      choices.each do |size, entry|
        item, dic = entry

        bonus = dic / dsize
        weight = weights[i] + (size + bonus) ** (1 + bonus)

        j = i + size
        if weight >= weights[j]
          weights[j] = weight
          selects[j] = Token.new(item.key, item.vals[0], dic)
        end
      end
    end

    idx = input.size
    res = [] of Token

    while idx > 0
      token = selects[idx]
      res << token
      idx -= token.key.size
    end

    combine_similar(res)
  end

  def combine_similar(tokens)
    res = [] of Token
    idx = tokens.size - 1

    while idx >= 0
      acc = tokens[idx]
      jdx = idx - 1

      if acc.dic == 0
        while jdx >= 0
          cur = tokens[jdx]
          break if cur.dic > 0
          break unless similar?(acc, cur)
          acc.key += cur.key
          acc.val += cur.val
          jdx -= 1
        end
      end

      idx = jdx
      res << acc
    end

    res
  end

  private def similar?(acc : Token, cur : Token)
    return true if acc.key[0] == cur.key[0]
    return true if acc.key == acc.val && cur.key == cur.val

    letter?(cur) && letter?(acc)
  end

  private def letter?(tok : Token)
    case tok.key[0]
    when .alphanumeric?, ':', '/', '?', '-', '_', '%'
      # match letter or uri scheme
      true
    else
      # match normalizabled chars
      tok.val[0].alphanumeric?
    end
  end

  def apply_grammar
    # TODO: handle more special rules, like:
    # - convert hanzi to number,
    # - convert hanzi percent
    # - date and time
    # - guess special words meaning..
    # - apply `的` grammar
    # - apply other grammar rule
    # - ...

    @tokens.each do |token|
      if token.key == "的"
        token.val = ""
        token.dic = 0
      end
    end

    self
  end

  def capitalize(cap_first : Bool = true)
    apply_cap = cap_first

    @tokens.each do |token|
      next if token.val.empty?

      if apply_cap && token.val[0].alphanumeric?
        token.val = Util.capitalize(token.val)
        apply_cap = false
      else
        apply_cap ||= cap_after?(token.val)
      end
    end

    self
  end

  private def cap_after?(val : String)
    return false if val.empty?
    case val[-1]
    when '“', '‘', '⟨', '[', '{', '.', ':', '!', '?'
      return true
    else
      return false
    end
  end

  def add_spaces
    res = Array(Token).new
    add_space = false

    @tokens.each do |token|
      next if token.val.empty?

      res << Token.new("", " ", 0) if add_space && space_before?(token.val[0])
      res << token
      add_space = token.dic > 0 || space_after?(token.val[-1])
    end

    @tokens = res
    self
  end

  def to_s(io : IO)
    @tokens.each do |token|
      io << token.val
    end
  end

  def to_json(json : JSON::Builder)
    @tokens.to_json(json)
  end

  private def space_before?(char : Char)
    case char
    when '”', '’', '⟩', ')', ']',
         '}', ',', '.', ':', ';',
         '!', '?', '%', ' ', '_',
         '…', '/', '\\', '~'
      false
    else
      true
    end
  end

  private def space_after?(char : Char)
    case char
    when '“', '‘', '⟨', '(', '[',
         '{', ' ', '_', '/', '\\'
      false
    else
      true
    end
  end
end
