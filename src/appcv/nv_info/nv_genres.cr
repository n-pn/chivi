require "./nv_utils"

module CV::NvGenres
  extend self

  DIR = "_db/nv_infos/genres"
  ::FileUtils.mkdir_p(DIR)

  class_getter _index : ValueMap { ValueMap.new "#{DIR}/_index.tsv" }

  class_getter map_vi : TokenMap { TokenMap.new "#{DIR}/map_vi.tsv" }

  class_getter fix_zh : ValueMap { NvUtils.fix_map("bgenres_zh") }
  class_getter fix_vi : ValueMap { NvUtils.fix_map("bgenres_vi") }

  delegate get, to: _index
  delegate each, to: _index

  def set!(bname : String, genres : Array(String), force = false)
    return unless force || !_index.has_key?(bname)
    map_vi.set!(bname, genres.map { |x| TextUtils.slugify(x) })
    _index.set!(bname, genres)
  end

  def filter(inp : String, prevs : Set(String)? = nil)
    res = map_vi.keys(TextUtils.slugify(inp))
    prevs ? prevs & res : res
  end

  def fix_zh_name(zh_name : String) : Array(String)
    fix_zh.get(zh_name) || [] of String
  end

  def fix_vi_name(zh_name : String) : String
    fix_vi.fval(zh_name) || NvUtils.to_hanviet(zh_name)
  end

  def save!(clean = false)
    @@_index.try(&.save!(clean: clean))

    @@map_vi.try(&.save!(clean: clean))
  end
end
