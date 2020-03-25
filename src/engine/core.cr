require "./dict"
require "./util"

require "./core/*"

module Engine::Core
  extend self

  alias Tokens = Array(Token)
  alias Dicts = Array(Dict)
  alias Chars = Array(Char)

  # do not add capitalize and spaces, suit for tradsimp conversion
  def cv_raw(dicts : Dicts, input : String)
    tokenize(dicts, input.chars)
  end

  # only add space, for transliteration like hanviet or pinyins
  def cv_lit(dicts : Dicts, input : String)
    chars = Util.normalize(input)
    tokens = tokenize(dicts, chars)
    tokens = group_similar(tokens)
    add_space(tokens)
  end

  # apply spaces, caps and grammars, suit for vietphase translation
  def cv_plain(dicts : Dicts, input : String)
    chars = Util.normalize(input)
    tokens = tokenize(dicts, chars)
    tokens = group_similar(tokens)
    tokens = fix_grammar(tokens)
    tokens = capitalize(tokens)
    add_space(tokens)
  end

  # take extra care for chapter titles
  def cv_title(dicts : Dicts, input : String)
    if match = split_head(input)
      head_text, head_trash, zh_index, vi_index, tail_trash, tail_text = match

      output = Tokens.new

      if !head_text.empty?
        output.concat cv_plain(dicts, head_text)
        output << Token.new(head_trash, " - ", 0)
      elsif !head_trash.empty?
        output << Token.new(head_trash, "", 0)
      end

      output << Token.new(zh_index, vi_index, 0)

      if !tail_text.empty?
        output << Token.new(tail_trash, ": ", 0)
        output.concat cv_title(dicts, tail_text) # incase volume title is mixed with chapter title
      elsif !tail_trash.empty?
        output << Token.new(tail_trash, "", 0)
      end

      output
    else
      cv_plain(dicts, input)
    end
  end

  NUMBER  = "零〇一二三四五六七八九十百千"
  LABELS  = "章节幕回集卷"
  HEAD_RE = /^(.*?)(\s*)(第?([\d#{NUMBER}]+)([#{LABELS}]))([,.:]?\s*)(.*)$/

  # split chapter title and translate chapter index
  def split_head(input : String)
    if match = input.match(HEAD_RE)
      vi_index = vi_label(match[5]) + " " + Util.hanzi_int(match[4])
      {match[1], match[2], match[3], vi_index, match[6], match[7]}
    else
      nil
    end
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
end
