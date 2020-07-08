require "./cv_dict"
require "./cv_data"

require "../_utils/fix_titles"
require "../_utils/han_to_int"
require "../_utils/normalize"

module Convert
  extend self

  def translit(input : String, dict : CvDict, apply_cap = false, pad_space = true)
    res = tokenize(input.chars, dict)
    res.capitalize! if apply_cap
    res.pad_spaces! if pad_space

    res
  end

  def cv_plain(input : String, *dicts : CvDict)
    res = tokenize(input.chars, *dicts)
    res.grammarize!
    res.capitalize!
    res.pad_spaces!
    res
  end

  TITLE_RE = /^(第([零〇一二两三四五六七八九十百千]+|\d+)([集卷章节幕回]))([,.:\s]*)(.*)$/

  def cv_title(input : String, *dicts : CvDict)
    res = CvData.new

    title, label = Utils.split_label(input)
    unless label.empty? || label == "正文"
      if match = TITLE_RE.match(label)
        _, group, idx, tag, trash, label = match

        num = Utils.han_to_int(idx)
        res << CvData::Node.new(group, "#{cv_title_tag(tag)} #{num}", 1)

        if !label.empty?
          res << CvData::Node.new(trash, ": ", 0)
        elsif !trash.empty?
          res << CvData::Node.new(trash, "", 0)
        end
      end

      unless label.empty?
        res.concat(cv_plain(label, *dicts))
        res << CvData::Node.new("", " - ", 0) unless title.empty?
      end
    end

    unless title.empty?
      if match = TITLE_RE.match(title)
        _, group, idx, tag, trash, title = match

        num = Utils.han_to_int(idx)
        res << CvData::Node.new(group, "#{cv_title_tag(tag)} #{num}", 1)

        if !title.empty?
          res << CvData::Node.new(trash, ": ", 0)
        elsif !trash.empty?
          res << CvData::Node.new(trash, "", 0)
        end
      end

      res.concat(cv_plain(title, *dicts)) unless title.empty?
    end

    res
  end

  private def cv_title_tag(label = "")
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

  def tokenize(chars : Array(Char), *dicts : CvDict)
    choices = [CvData::Node.new("", "")]
    weights = [0.0]

    norms = chars.map_with_index do |char, idx|
      norm = Utils.normalize(char)

      weights << idx + 1.0
      choices << CvData::Node.new(char, norm, 0)

      norm
    end

    dict_count = dicts.size + 1
    char_count = chars.size + 1

    0.upto(chars.size) do |idx|
      pos_weight = (char_count - idx) / char_count

      dicts.each_with_index do |dict, jdx|
        dic = jdx + 1
        dic_weight = dic / dict_count + 1

        dict.scan(norms, idx) do |item|
          length = item.key.size
          weight = weights[idx] + pos_weight + length ** (1 + dic_weight)

          jdx = idx + length
          if weight >= weights[jdx]
            weights[jdx] = weight
            choices[jdx] = CvData::Node.new(item.key, item.vals[0], dic, item.extra)
          end
        end
      end
    end

    res = CvData.new
    idx = chars.size

    while idx > 0
      acc = choices[idx]
      idx -= acc.key.size

      if acc.dic == 0
        if acc.match_letter?
          acc.dic = 1

          while idx > 0
            node = choices[idx]
            break if node.dic > 0
            break unless node.special_char? || node.match_letter?

            acc.combine!(node)
            idx -= node.key.size
          end
        elsif acc.unchanged?
          while idx > 0
            node = choices[idx]
            break if node.dic > 0
            break unless node.unchanged?

            acc.combine!(node)
            idx -= node.key.size
          end
        end
      end

      res << acc
    end

    res.data.reverse!
    res
  end
end
