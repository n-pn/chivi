require "json"

require "./cv_dict"
require "./cv_node"

require "../../_utils/normalize"
require "../../_utils/han_to_int"
require "../../_utils/string_utils"

module CvCore
  extend self

  alias DictPair = Tuple(CvDict, CvDict)

  def cv_raw(input : String, dpair : DictPair)
    tokenize(input.chars, [dpair]).reverse
  end

  def cv_lit(input : String, dpair : DictPair, apply_cap = false)
    nodes = tokenize(input.chars, [dpair])
    nodes = combine_similar(nodes)
    nodes = capitalize(nodes) if apply_cap
    add_spaces(nodes)
  end

  def cv_plain(input : String, dicts : Array(DictPair))
    nodes = tokenize(input.chars, dicts)
    nodes = combine_similar(nodes)
    nodes = apply_grammar(nodes)
    nodes = capitalize(nodes)
    add_spaces(nodes)
  end

  TITLE_RE = /^(第([零〇一二两三四五六七八九十百千]+|\d+)([集卷章节幕回]))([,.:]*)(.*)$/

  def cv_title(input : String, dicts : Array(DictPair))
    res = CvNodes.new
    space = false

    input.split(" ") do |title|
      res << CvNode.new("", " ", 0) if space

      if match = TITLE_RE.match(title)
        _, group, index, label, trash, title = match

        res << CvNode.new(group, vi_title(index, label), 0)
        res << CvNode.new(trash, ":", 0) # unless trash.empty?
        res << CvNode.new("", " ", 0) unless title.empty?
      end

      res.concat(cv_plain(title, dicts)) unless title.empty?
      space = true
    end

    res
  end

  private def vi_title(index : String, label = "")
    int = Utils.han_to_int(index)

    case label
    when "章" then "Chương #{int}"
    when "卷" then "Quyển #{int}"
    when "集" then "Tập #{int}"
    when "节" then "Tiết #{int}"
    when "幕" then "Màn #{int}"
    when "回" then "Hồi #{int}"
    when "折" then "Chiết #{int}"
    else          "Chương #{int}"
    end
  end

  private def tokenize(chars : Array(Char), dicts : Array(DictPair))
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

      dicts.each_with_index do |(root_dict, user_dict), jdx|
        dict_index = jdx + 1
        dict_bonus = dict_index / dict_count

        items = {} of Int32 => CvDict::Item

        root_dict.scan(norms, idx).each do |item|
          key = item.key.size
          items[key] = item
        end

        user_dict.scan(norms, idx).each do |item|
          key = item.key.size
          items[key] = item
        end

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

    idx = chars.size
    res = CvNodes.new

    while idx > 0
      node = selects[idx]
      res << node
      idx -= node.key.size
    end

    res
  end

  private def combine_similar(nodes : CvNodes)
    res = CvNodes.new
    idx = nodes.size - 1

    while idx >= 0
      acc = nodes[idx]
      jdx = idx - 1

      if acc.dic == 0
        while jdx >= 0
          cur = nodes[jdx]
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

  private def similar?(acc : CvNode, cur : CvNode)
    return true if acc.key[0] == cur.key[0]
    return true if acc.key == acc.val && cur.key == cur.val

    letter?(cur) && letter?(acc)
  end

  private def letter?(node : CvNode)
    case node.key[0]
    when .alphanumeric?, ':', '/', '?', '-', '_', '%'
      # match letter or uri scheme
      true
    else
      # match normalizabled chars
      node.val[0].alphanumeric?
    end
  end

  def apply_grammar(nodes : CvNodes)
    # TODO: handle more special rules, like:
    # - convert hanzi to number,
    # - convert hanzi percent
    # - date and time
    # - guess special words meaning..
    # - apply `的` grammar
    # - apply other grammar rule
    # - ...

    nodes.each do |node|
      if node.key == "的"
        node.val = ""
        node.dic = 0
      end
    end

    nodes
  end

  def capitalize(nodes : CvNodes, cap_first : Bool = true)
    apply_cap = cap_first

    nodes.each do |node|
      next if node.val.empty?

      if apply_cap && node.val =~ /[\p{L}\p{N}]/
        node.val = Utils.capitalize(node.val)
        apply_cap = false
      else
        apply_cap ||= cap_after?(node.val)
      end
    end

    nodes
  end

  private def cap_after?(val : String)
    case val[-1]
    when '“', '‘', '⟨', '[', '{', '.', ':', '!', '?'
      return true
    else
      return false
    end
  end

  def add_spaces(nodes : CvNodes)
    res = CvNodes.new
    add_space = false

    nodes.each do |node|
      if node.val.empty?
        res << node
      else
        res << CvNode.new("", " ", 0) if add_space && space_before?(node.val[0])
        res << node
        add_space = node.dic > 0 || space_after?(node.val[-1])
      end
    end

    res
  end

  private def space_before?(char : Char)
    case char
    when '”', '’', '⟩', ')', ']', '}', ',', '.', ':', ';',
         '!', '?', '%', ' ', '_', '…', '/', '\\', '~'
      false
    else
      true
    end
  end

  private def space_after?(char : Char)
    case char
    when '“', '‘', '⟨', '(', '[', '{', ' ', '_', '/', '\\'
      false
    else
      true
    end
  end
end
