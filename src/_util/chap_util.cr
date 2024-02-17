require "./char_util"
require "./text_util"

module ChapUtil
  extend self

  ###

  NUMS = "零〇一二两三四五六七八九十百千"
  VOLS = "集卷季"

  DIVS = {
    /^(第?[#{NUMS}\d]+[#{VOLS}].*?)(第?[#{NUMS}\d]+[章节幕回折].*)$/,
    # /^(第?[#{NUMS}\d]+[#{VOLS}].*?)(（\p{N}+）.*)$/,
    /^【(第?[#{NUMS}\d]+[#{VOLS}])】(.+)$/,
  }

  def split_ztitle(title : String, chdiv = "", cleaned : Bool = false) : Tuple(String, String)
    title = TextUtil.format_and_clean(title) unless cleaned
    return {title, chdiv} unless chdiv.empty?

    DIVS.each do |regex|
      next unless match = regex.match(title)
      title = match[2].lstrip('　')
      chdiv = match[1].rstrip('　')
      break
    end

    {title, chdiv}
  end

  def clean_zchdiv(chdiv : String)
    chdiv = chdiv.gsub(/《.*》/, "").gsub(/\n|\t|\s{2,}/, '　')
    TextUtil.format_and_clean(chdiv)
  end
end
