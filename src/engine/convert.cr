require "./convert/cv_core"

module Convert
  extend self

  alias DictPair = Tuple(CvDict, CvDict)

  def cv_raw(input : String, dpair : DictPair)
    CvCore.tokenize(input.chars, [dpair]).reverse
  end

  def cv_lit(input : String, dpair : DictPair, apply_cap = false)
    nodes = CvCore.tokenize(input.chars, [dpair])
    nodes = CvCore.combine_similar(nodes)
    nodes = CvCore.capitalize(nodes) if apply_cap
    CvCore.add_spaces(nodes)
  end

  def cv_plain(input : String, dicts : Array(DictPair))
    nodes = CvCore.tokenize(input.chars, dicts)
    nodes = CvCore.combine_similar(nodes)
    nodes = CvCore.apply_grammar(nodes)
    nodes = CvCore.capitalize(nodes)
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
end
