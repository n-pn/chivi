module Utils
  NUMBERS = "零〇一二两三四五六七八九十百千"

  VOL_RE_0 = /^(第[#{NUMBERS}\d]+[集卷].*)(第?[#{NUMBERS}\d]+[章节幕回].*)$/
  VOL_RE_1 = /^(第[#{NUMBERS}\d]+[集卷].*)(（\p{N}+）.*)$/

  def self.split_title(title)
    volume = "正文"
    if match = VOL_RE_0.match(title) || VOL_RE_1.match(title)
      _, volume, title = match
      volume = clean_title(volume)
    end

    {fix_title(title), volume}
  end

  TITLE_RE_0 = /^\d+\.\s*第/
  TITLE_RE_1 = /^第?([#{NUMBERS}\d]+)([章节幕回折])[、：,.:\s]?(.*)$/
  TITLE_RE_2 = /^([#{NUMBERS}\d]+)[、：,.:\s]?(.*)$/
  TITLE_RE_3 = /^（(\p{N}+)）(.*)$/

  def self.fix_title(title)
    if match = TITLE_RE_0.match(title)
      return clean_title(title.sub(/^\d+\.\s*第/, "第"))
    end

    label = "章"

    if match = TITLE_RE_1.match(title)
      _, number, label, title = match
    elsif match = TITLE_RE_2.match(title)
      _, number, title = match
    elsif match = TITLE_RE_3.match(title)
      _, number, title = match
    else
    end

    clean_title("第#{number}#{label} #{title}")
  end

  def self.clean_title(title)
    title.strip.split(/\p{Z}+/).join(" ")
  end
end

# puts Utils.split_title("第一集 汉宫日暮 第一章　　长门灯暗")
# puts Utils.split_title("第一集 第一章　　长门灯暗")
# puts Utils.split_title("第一集 第一章")
# puts Utils.split_title("第一集第一章")
# puts Utils.split_title("第一章　　长门灯暗")
# puts Utils.split_title("第一章")
# puts Utils.split_title("123.第一章")
# puts Utils.split_title("第1集 昆仑钟鼓 第一章 世称神童 青云直跃")
# puts Utils.split_title("二、人肉吸奶器")
# puts Utils.split_title("四十七")
# puts Utils.split_title("第一集（9）少女诱惑")
