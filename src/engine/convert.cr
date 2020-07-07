require "../filedb/lx_pair"
require "./convert/cv_node"
require "./convert/cv_data"

require "../_utils/fix_titles"
require "../_utils/han_to_int"
require "../_utils/normalize"

module Convert
  extend self

  alias LxList = Array(LxPair)

  def cvraw(input : String, dicts : LxPair)
    tokenize(input.chars, [dicts])
  end

  def cvlit(input : String, dicts : LxPair, apply_cap = false)
    nodes = tokenize(input.chars, [dicts])
    nodes.capitalize! if apply_cap
    nodes.pad_spaces!
  end

  def plain(input : String, dicts : Array(LxPair))
    nodes = tokenize(input.chars, dicts)
    nodes.grammarize!.capitalize!.pad_spaces!
  end

  TITLE_RE = /^(第([零〇一二两三四五六七八九十百千]+|\d+)([集卷章节幕回]))([,.:\s]*)(.*)$/

  def title(input : String, dicts : Array(LxPair))
    nodes = CvData.new
    space = false

    title, volume = Utils.split_title(input)

    unless volume.empty? || volume == "正文"
      if match = TITLE_RE.match(volume)
        _, group, index, label, trash, volume = match

        index = Utils.han_to_int(index)
        nodes << CvNode.new(group, "#{cv_label(label)} #{index}", 0)

        if !volume.empty?
          nodes << CvNode.new(trash, ": ", 0)
        elsif !trash.empty?
          nodes << CvNode.new(trash, "", 0)
        end
      end

      unless volume.empty?
        nodes.concat(plain(volume, dicts))
        nodes << CvNode.new("", " - ", 0) unless title.empty?
      end
    end

    unless title.empty?
      if match = TITLE_RE.match(title)
        _, group, index, label, trash, title = match

        index = Utils.han_to_int(index)
        nodes << CvNode.new(group, "#{cv_label(label)} #{index}", 0)

        if !title.empty?
          nodes << CvNode.new(trash, ": ", 0)
        elsif !trash.empty?
          nodes << CvNode.new(trash, "", 0)
        end
      end

      nodes.concat(plain(title, dicts)) unless title.empty?
    end

    nodes
  end

  private def cv_label(label = "")
    case label
    when "章" then "Chương"
    when "卷" then "Quyển"
    when "集" then "Tập"
    when "节" then "Tiết"
    when "幕" then "Màn"
    when "回" then "Hồi"
    when "折" then "Chiết"
    else          "Chương"
    end
  end

  def tokenize(chars : Array(Char), dicts : LxList)
    dict_count = dicts.size + 1
    char_count = chars.size + 1

    selects = [CvNode.new("", "")]
    weights = [0.0]

    norms = chars.map_with_index do |char, idx|
      norm = Utils.normalize(char)

      weights << idx + 1.0
      selects << CvNode.new(char, norm)

      norm
    end

    0.upto(chars.size) do |idx|
      init_bonus = (char_count - idx) / char_count + 1

      dicts.each_with_index do |dpair, jdx|
        dict_index = jdx + 1
        dict_bonus = dict_index / dict_count

        items = dpair.scan(norms, idx)
        items.each do |size, item|
          next if item.vals.empty?
          next if item.vals.first.empty?

          item_weight = (size + dict_bonus ** init_bonus) ** (1 + dict_bonus)
          gain_weight = weights[idx] + item_weight

          jdx = idx + size
          if gain_weight > weights[jdx]
            weights[jdx] = gain_weight
            selects[jdx] = CvNode.new(item.key, item.vals[0], dict_index)
          end
        end
      end
    end

    nodes = [] of CvNode
    index = chars.size

    while index > 0
      node = selects[index]
      nodes << node
      index -= node.key.size
    end

    combine_similar(nodes)
  end

  private def combine_similar(input : Array(CvNode)) : CvData
    nodes = CvData.new
    index = input.size - 1

    while index >= 0
      acc = input[index]
      jdx = index - 1

      if acc.dic == 0
        if acc.key[0].alphanumeric?
          while jdx >= 0
            cur = input[jdx]
            break unless letter?(cur.key[0])

            acc.key += cur.key
            acc.val += cur.val
            jdx -= 1
          end

          acc.dic = 1
        else
          while jdx >= 0
            cur = input[jdx]
            break unless cur.key[0] == acc.key[0]

            acc.key += cur.key
            acc.val += cur.val
            jdx -= 1
          end
        end
      end

      index = jdx
      nodes << acc
    end

    nodes
  end

  private def letter?(char : Char) : Bool
    case char
    when '_', '.', '%', '-', '/', '?', '=', ':'
      true
    else
      char.alphanumeric?
    end
  end
end
