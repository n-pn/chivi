require "./nv_utils"

module CV::NvAuthor
  extend self

  DIR = "_db/nv_infos/authors"
  ::FileUtils.mkdir_p(DIR)

  class_getter _index : ValueMap { ValueMap.new "#{DIR}/_index.tsv" }

  class_getter map_zh : TokenMap { TokenMap.new "#{DIR}/map_zh.tsv" }
  class_getter map_vi : TokenMap { TokenMap.new "#{DIR}/map_vi.tsv" }

  class_getter fix_zh : ValueMap { NvUtils.fix_map("authors_zh") }
  class_getter fix_vi : ValueMap { NvUtils.fix_map("authors_vi") }

  delegate get, to: _index
  delegate each, to: _index

  def set!(bname : String, zh_name : String, vi_name = fix_vi_name(zh_name))
    map_zh.set!(bname, TextUtils.tokenize(zh_name))
    map_vi.set!(bname, TextUtils.tokenize(vi_name))

    _index.set!(bname, [zh_name, vi_name])
  end

  class_getter zh_names : Set(String) do
    names = Set(String).new
    _index.data.each_value { |vals| names.add(vals[0]) }
    names
  end

  def exists?(zh_name : String)
    zh_names.includes?(zh_name)
  end

  def filter(inp : String, prevs : Set(String)? = nil)
    tsv = TextUtils.tokenize(inp)
    res = inp =~ /\p{Han}/ ? map_zh.keys(tsv) : map_vi.keys(tsv)

    prevs ? prevs & res : res
  end

  def fix_zh_name(author : String, btitle : String = "") : String
    author = NvUtils.cleanup_name(author).sub(/\.QD\s*$/, "")
    fix_zh.fval("#{btitle}  #{author}") || fix_zh.fval(author) || author
  end

  def fix_vi_name(zh_name : String) : String
    fix_vi.fval(zh_name) || NvUtils.to_hanviet(zh_name)
  end

  def save!(clean = false)
    @@_index.try(&.save!(clean: clean))

    @@map_zh.try(&.save!(clean: clean))
    @@map_vi.try(&.save!(clean: clean))
  end
end
