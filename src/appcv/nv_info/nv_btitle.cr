require "./nv_utils"

module CV::NvBtitle
  extend self

  DIR = "_db/nv_infos/btitles"
  ::FileUtils.mkdir_p(DIR)

  class_getter _index : ValueMap { ValueMap.new "#{DIR}/_index.tsv" }

  class_getter map_zh : TokenMap { TokenMap.new "#{DIR}/map_zh.tsv" }
  class_getter map_hv : TokenMap { TokenMap.new "#{DIR}/map_hv.tsv" }
  class_getter map_vi : TokenMap { TokenMap.new "#{DIR}/map_vi.tsv" }

  class_getter fix_zh : ValueMap { NvUtils.fix_map("btitles_zh") }
  class_getter fix_vi : ValueMap { NvUtils.fix_map("btitles_vi") }

  delegate get, to: _index
  delegate each, to: _index

  def set!(bname : String, zh_name : String, hv_name = NvUtils.to_hanviet(zh_name), vi_name = fix_vi_name(zh_name))
    map_zh.set!(bname, TextUtils.tokenize(zh_name))
    map_hv.set!(bname, TextUtils.tokenize(hv_name))
    map_vi.set!(bname, TextUtils.tokenize(vi_name)) if hv_name != vi_name

    _index.set!(bname, [zh_name, hv_name, vi_name])
  end

  def filter(inp : String, prevs : Set(String)? = nil)
    tsv = TextUtils.tokenize(inp)
    res = inp =~ /\p{Han}/ ? map_zh.keys(tsv) : map_hv.keys(tsv) + map_vi.keys(tsv)

    prevs ? prevs & res : res
  end

  def fix_zh_name(btitle : String, author : String = "") : String
    btitle = NvUtils.cleanup_name(btitle)
    fix_zh.fval("#{btitle}  #{author}") || fix_zh.fval(btitle) || btitle
  end

  def fix_vi_name(zh_name : String) : String
    fix_vi.fval(zh_name).try { |x| TextUtils.titleize(x) } || NvUtils.to_hanviet(zh_name)
  end

  def save!(clean = false)
    @@_index.try(&.save!(clean: clean))

    @@map_zh.try(&.save!(clean: clean))
    @@map_hv.try(&.save!(clean: clean))
    @@map_vi.try(&.save!(clean: clean))
  end
end
