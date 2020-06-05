module Utils
  # fixes chapter titles

  NUMS = "零〇一二两三四五六七八九十百千"
  LBLS = "章节幕回折"
  SEPS = ".，,、：:"

  SPLIT_RE_0 = /^(第[#{NUMS}\d]+[集卷].*?)(第?[#{NUMS}\d]+[#{LBLS}].*)$/
  SPLIT_RE_1 = /^(第[#{NUMS}\d]+[集卷].*?)(（\p{N}+）.*)$/
  SPLIT_RE_2 = /^【(第[#{NUMS}\d]+[集卷])】(.+)$/

  def self.split_title(title : String)
    volume = "正文"

    if match = SPLIT_RE_0.match(title) || SPLIT_RE_1.match(title) || SPLIT_RE_2.match(title)
      _, volume, title = match
      volume = clean_title(volume)
    end

    {fix_title(title), volume}
  end

  TITLE_RE_0 = /^第?([#{NUMS}\d]+)([#{LBLS}])[#{SEPS}\s]*(.*)$/
  TITLE_RE_1 = /^([#{NUMS}\d]+)[#{SEPS}\s]*(.*)$/
  TITLE_RE_2 = /^（(\p{N}+)）[#{SEPS}\s]*(.*)$/
  TITLE_RE_3 = /^(\d+)\.\s*第.+[#{LBLS}][#{SEPS}\s]*(.+)/ # 69shu

  def self.fix_title(title : String)
    if match = TITLE_RE_0.match(title)
      _, number, label, title = match
      return "第#{number}#{label} #{clean_title(title)}"
    end

    if match = TITLE_RE_1.match(title) || TITLE_RE_2.match(title) || TITLE_RE_3.match(title)
      _, number, title = match
      return "#{number}. #{clean_title(title)}"
    end

    return clean_title(title)
  end

  def self.clean_title(title)
    title.strip.split(/\p{Z}+/).join(" ")
  end
end
