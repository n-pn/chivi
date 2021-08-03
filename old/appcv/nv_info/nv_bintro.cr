require "./nv_utils"

module CV::NvBintro
  extend self

  DIR = "_db/nv_infos/intros"
  ::FileUtils.mkdir_p(DIR)

  CACHE = {} of String => ValueMap

  def intro_map(bhash : String, lang = "vi")
    label = "#{bhash[0]}#{bhash[1]}-#{lang}"
    CACHE[label] ||= ValueMap.new("#{DIR}/#{label}.tsv")
  end

  def get(bhash : String, lang = "vi") : Array(String)
    intro_map(bhash, lang).get(bhash) || [""]
  end

  def set!(bhash : String, lines : Array(String), force = false) : Nil
    zh_map = intro_map(bhash, "zh")
    return unless force || !zh_map.has_key?(bhash)

    zh_map.set!(bhash, lines)

    libcv = Cvmtl.generic(bhash)
    intro = lines.map { |line| libcv.cv_plain(line).to_s }

    intro_map(bhash, "vi").set!(bhash, intro)
  end

  def save!(clean = false)
    CACHE.each_value(&.save!(clean: clean))
  end
end
