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

  getter hanviet : String do
    MtCore.hanviet_mtl.translit(@key).to_s
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "uniq" { vp_to_json(jb, @dicts[0], @dicts[1], uniq: true) }
      jb.field "core" { vp_to_json(jb, @dicts[2], @dicts[3]) }
      VpDict.suggest.find(@key).try { |term| add_hints(term, deep_loop: false) }

      unless @mt_tag.empty?
        @vals.push({@mt_val, 0})
        @tags.push({@mt_tag, 0})
      end

      jb.field "vals", @vals.uniq(&.[0])
      jb.field "tags", @tags.uniq(&.[0])

      jb.field "binh_am", MtCore.binh_am_mtl.translit(@key).to_s
      jb.field "hanviet" { hv_to_json(jb) }
    end
  end

  def hv_to_json(jb : JSON::Builder)
    term = VpDict.hanviet.find(@key)

    jb.object do
      if term
        jb.field "val", term.val.first
        jb.field "rank", term.rank

        jb.field "p_mtime", term.mtime
        jb.field "p_uname", term.uname
        jb.field "p_state", term.state
      else
        jb.field "val", hanviet
        jb.field "rank", 3
      end
    end
  end

  def vp_to_json(jb : JSON::Builder, priv_dict : VpDict, publ_dict : VpDict, uniq = false)
    priv = priv_dict.find(@key)
    publ = publ_dict.find(@key)

    jb.object do
      if priv
        add_hints(priv)

        jb.field "val", priv.val.first
        jb.field "ptag", priv.ptag.to_str
        jb.field "rank", priv.rank

        jb.field "u_mtime", priv.mtime
        jb.field "u_state", priv.state

        if publ
          jb.field "p_mtime", publ.mtime
          jb.field "p_uname", publ.uname
          jb.field "p_state", publ.state
        end
      elsif publ
        add_hints(publ)

        jb.field "val", publ.val.first
        jb.field "ptag", publ.ptag.to_str
        jb.field "rank", publ.rank

        jb.field "p_mtime", publ.mtime
        jb.field "p_uname", publ.uname
        jb.field "p_state", publ.state
      elsif uniq && @mt_tag.empty?
        jb.field "val", TextUtils.titleize(hanviet)
        jb.field "ptag", "nr"
        jb.field "rank", 3
        jb.field "fresh", true
      else
        jb.field "val", @mt_val
        jb.field "ptag", @mt_tag
        jb.field "rank", 3
        jb.field "fresh", true
      end
    end
  end

  def add_hints(term : VpTerm, deep_loop = true)
    dic = term.dtype

    term.val.each { |val| @vals << ({val, dic}) }
    @tags << {term.ptag.to_str, dic}

    return unless deep_loop

    while prev = term._prev
      prev.val.each { |val| @vals << ({val, dic}) }
      @tags << {term.ptag.to_str, dic}
      term = prev
    end
  end
end
