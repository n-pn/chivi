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

  def tokenize!(dicts : Array(Dict), input : Array(Char))
    selects = [Token.new("", "")]
    weights = [0.0]

    chars = Util.normalize(input)

    input.each_with_index do |char, idx|
      selects << Token.new(char, chars[idx])
      weights << idx + 1.0
    end

    dsize = dicts.size + 1

    chars.each_with_index do |char, i|
      choices = {} of Int32 => Tuple(Dict::Item, Int32)

      dicts.each_with_index do |dict, j|
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

    @tokens = [] of Token

    idx = res.size - 1
    while idx >= 0
      acc = res[idx]
      jdx = idx - 1

      if acc.dic == 0
        while jdx >= 0
          cur = res[jdx]
          break if cur.dic > 0
          break unless similar?(acc, cur)
          acc.key += cur.key
          acc.val += cur.val
          jdx -= 1
        end
      end

      @tokens << acc
      idx = jdx
    end

    self
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

  def apply_grammar!
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

  def capitalize!(cap_first : Bool = true)
    apply_cap = cap_first

    @tokens.each do |token|
      if apply_cap && consume_cap?(token.val)
        token.val = Util.capitalize(token.val)
        apply_cap = false
      else
        apply_cap ||= cap_after?(token.key)
      end
    end

    self
  end

  private def consume_cap?(val : String)
    return false if val.empty?
    val[0].alphanumeric?
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

  def add_spaces!
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

  # # do not add capitalize and spaces, suit for tradsimp conversion
  # def cv_raw(dicts : Dicts, input : String)
  #   tokenize(dicts, input.chars)
  # end

  # # only add space, for transliteration like hanviet or pinyins
  # def cv_lit(dicts : Dicts, input : String)
  #   chars = Util.normalize(input)
  #   tokens = tokenize(dicts, chars)
  #   tokens = group_similar(tokens)
  #   add_space(tokens)
  # end

  # # apply spaces, caps and grammars, suit for vietphase translation
  # def cv_plain(dicts : Dicts, input : String)
  #   chars = Util.normalize(input)
  #   tokens = tokenize(dicts, chars)
  #   tokens = group_similar(tokens)
  #   tokens = apply_grammar(tokens)
  #   tokens = capitalize(tokens)
  #   add_space(tokens)
  # end

  # # take extra care for chapter titles
  # def cv_title(dicts : Dicts, input : String)
  #   if match = split_head(input)
  #     head_text, head_trash, zh_index, vi_index, tail_trash, tail_text = match

  #     output = Tokens.new

  #     if !head_text.empty?
  #       output.concat cv_plain(dicts, head_text)
  #       output << Token.new(head_trash, " - ", 0)
  #     elsif !head_trash.empty?
  #       output << Token.new(head_trash, "", 0)
  #     end

  #     output << Token.new(zh_index, vi_index, 0)

  #     if !tail_text.empty?
  #       output << Token.new(tail_trash, ": ", 0)
  #       output.concat cv_title(dicts, tail_text) # incase volume title is mixed with chapter title
  #     elsif !tail_trash.empty?
  #       output << Token.new(tail_trash, "", 0)
  #     end

  #     output
  #   else
  #     cv_plain(dicts, input)
  #   end
  # end

  # NUMBER  = "零〇一二三四五六七八九十百千"
  # LABELS  = "章节幕回集卷"
  # HEAD_RE = /^(.*?)(\s*)(第?([\d#{NUMBER}]+)([#{LABELS}]))([,.:]?\s*)(.*)$/

  # # split chapter title and translate chapter index
  # def split_head(input : String)
  #   if match = input.match(HEAD_RE)
  #     vi_index = vi_label(match[5]) + " " + Util.hanzi_int(match[4])
  #     {match[1], match[2], match[3], vi_index, match[6], match[7]}
  #   else
  #     nil
  #   end
  # end

  # private def vi_label(label : String)
  #   case label
  #   when "章" then "Chương"
  #   when "卷" then "Quyển"
  #   when "集" then "Tập"
  #   when "节" then "Tiết"
  #   when "幕" then "Màn"
  #   when "回" then "Hồi"
  #   else          label
  #   end
  # end
end
