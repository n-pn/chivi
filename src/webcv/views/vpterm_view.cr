require "json"

class CV::VpTermView
  @vals = [] of Tuple(String, Int32)
  @tags = [] of Tuple(String, Int32)

  alias Dicts = Tuple(VpDict, VpDict, VpDict, VpDict)

  @mt_val : String
  @mt_tag : String

  def initialize(@key : String, @cvmtl : MtCore, @dicts : Dicts)
    mt_list = cvmtl.cv_plain(key, mode: 2, cap_mode: 0)

    @mt_val = mt_list.to_s
    @mt_tag = mt_list.first?.try { |x| x.succ ? "" : x.tag.to_str } || ""
  end

  def binh_am
    MtCore.binh_am_mtl.translit(@key).to_s
  end

  def hanviet
    MtCore.hanviet_mtl.translit(@key).to_s
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "0_5" { to_json(jb, get_term(@dicts[0])) }
      jb.field "0_4" { to_json(jb, get_term(@dicts[1])) }
      jb.field "1_3" { to_json(jb, get_term(@dicts[2])) }
      jb.field "1_2" { to_json(jb, get_term(@dicts[3])) }

      VpDict.suggest.find(@key).try do |term|
        term.val.each { |val| @vals << ({val, 1}) }
        @tags << ({term.ptag.to_str, 1})
      end

      jb.field "vals", @vals.uniq(&.[0])
      jb.field "tags", @tags.uniq(&.[0])

      jb.field "binh_am", binh_am
      jb.field "hanviet" do
        to_json(jb, get_term(VpDict.hanviet) { hanviet })
      end
    end
  end

  private def find_node(dict : VpDict)
    dict.trie.find(@key)
  end

  def get_term(dict : VpDict)
    dict.find(@key) || begin
      dict.new_term(@key, [yield], uname: "", mtime: 0_u32)
    end
  end

  def get_term(dict : VpDict)
    if term = dict.find(@key)
      dic = dict.dtype

      term.val.each { |val| @vals << ({val, dic}) }
      @tags << {term.ptag.to_str, dic}

      while prev = term._prev
        prev.val.each { |val| @vals << ({val, dic}) }
        @tags << {term.ptag.to_str, dic}
        term = prev
      end
    else
      term = dict.new_term(@key, [@mt_val], @mt_tag, uname: "", mtime: 0_u32)
    end

    term
  end

  def to_json(jb : JSON::Builder, term : VpTerm)
    jb.object do
      jb.field "val", term.val.first

      jb.field "ptag", term.ptag.to_str
      jb.field "rank", term.rank

      jb.field "mtime", term.mtime * 60 + VpTerm::EPOCH
      jb.field "uname", term.uname

      jb.field "state", term.empty? ? "Xoá" : (term._prev ? "Sửa" : "Thêm")
    end
  end
end
