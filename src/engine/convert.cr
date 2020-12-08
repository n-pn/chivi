require "./library"
require "./convert/*"

class Chivi::Convert
  class_getter hanviet : self { new(Library.hanviet) }
  class_getter binh_am : self { new(Library.binh_am) }
  class_getter tradsim : self { new(Library.tradsim) }

  MACHINES = {} of String => self

  def self.content(udict : String)
    MACHINES[udict] ||= new(Library.regular, Library.find_dict(udict))
  end

  def initialize(@bdict : VpDict, @udict : VpDict? = nil)
  end

  def translit(input : String, apply_cap : Bool = false)
    group = tokenize(input.chars)
    group.capitalize! if apply_cap
    group.pad_spaces!
  end

  def cv_plain(input : String)
    tokenize(input.chars).fix_grammar!.capitalize!.pad_spaces!
  end

  LABEL_RE_1 = /^(第?([零〇一二两三四五六七八九十百千]+|\d+)([集卷]))([,.:\s]*)(.*)$/

  TITLE_RE_1 = /^(第(.+)([章节幕回折])\s\d+\.)(\s)(.+)/
  TITLE_RE_2 = /^(第?([零〇一二两三四五六七八九十百千]+|\d+)([章节幕回]))([,.:\s]*)(.*)$/

  TITLE_RE_3 = /^((\d+)([,.:]))(\s*)(.+)$/
  TITLE_RE_4 = /^楔子(\s+)(.+)$/

  def cv_title(input : String)
    res = [] of CvEntry

    title, label = split_title(input)

    unless label.empty? || label == "正文"
      if match = LABEL_RE_1.match(label)
        _, group, idx, tag, trash, label = match

        num = DictUtils.to_integer(idx)
        res << CvEntry.new(group, "#{cv_title_tag(tag)} #{num}", 1)

        if !label.empty?
          res << CvEntry.new(trash, ": ", 0)
        elsif !trash.empty?
          res << CvEntry.new(trash, "", 0)
        end
      end

      if label.empty?
        res << CvEntry.new("", ": ", 0) unless title.empty?
      else
        res.concat(cv_plain(label).data)
        res << CvEntry.new("", " - ", 0) unless title.empty?
      end
    end

    unless title.empty?
      if match = TITLE_RE_1.match(title) || TITLE_RE_2.match(title)
        _, group, idx, tag, trash, title = match

        num = DictUtils.to_integer(idx)
        res << CvEntry.new(group, "#{cv_title_tag(tag)} #{num}", 1)

        if !title.empty?
          res << CvEntry.new(trash, ": ", 0)
        elsif !trash.empty?
          res << CvEntry.new(trash, "", 0)
        end
      elsif match = TITLE_RE_3.match(title)
        _, group, num, tag, trash, title = match
        res << CvEntry.new(group, "#{num}#{tag}", 1)

        if !title.empty?
          res << CvEntry.new(trash, " ", 0)
        elsif !trash.empty?
          res << CvEntry.new(trash, "", 0)
        end
      elsif match = TITLE_RE_4.match(title)
        _, trash, title = match
        res << CvEntry.new("楔子", "Phần đệm", 1)

        if !title.empty?
          res << CvEntry.new(trash, ": ", 0)
        elsif !trash.empty?
          res << CvEntry.new(trash, "", 0)
        end
      end

      title.split(/\s+/).each_with_index do |text, idx|
        res << CvEntry.new(" ", " ", 0) if idx > 0
        res.concat(cv_plain(text).data)
      end
    end

    CvGroup.new(res)
  end

  private def split_title(input : String)
    cols = SeedUtils.fix_title(input).split("  ")

    if title = cols[2]?
      {title, cols[1]}
    else
      {cols[1], ""}
    end
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

  private def tokenize(chars : Array(Char))
    token = CvToken.new(chars)

    token.size.times do |caret|
      token.weighing(@bdict, caret)
      token.weighing(@udict.not_nil!, caret) if @udict
    end

    token.to_group
  end
end
