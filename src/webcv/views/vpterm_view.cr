require "json"

class CV::VpTermView
  @vals = [] of Tuple(String, Int32)
  @tags = [] of Tuple(String, Int32)

  @mt_val : String
  @mt_tag : String

  alias Dicts = Tuple(VpDict, VpDict, VpDict, VpDict)

  def initialize(@key : String, @cvmtl : MtCore, @dicts : Dicts)
    mt_list = cvmtl.cv_plain(key, mode: 2, cap_mode: 0)

    @mt_val = mt_list.to_s
    @mt_tag = mt_list.first?.try { |x| x.succ ? "" : x.tag.to_str } || ""
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "upriv" { to_json(jb, @dicts[0], type: 1) }
      jb.field "ubase" { to_json(jb, @dicts[1], type: 1) }
      jb.field "cpriv" { to_json(jb, @dicts[2], type: 0) }
      jb.field "cbase" { to_json(jb, @dicts[3], type: 0) }

      VpDict.suggest.find(@key).try { |term| add_hints(term, deep_loop: false) }

      unless @mt_tag.empty?
        @vals.push({@mt_val, 0})
        @tags.push({@mt_tag, 0})
      end

      jb.field "vals", @vals.uniq(&.[0])
      jb.field "tags", @tags.uniq(&.[0])

      jb.field "binh_am", MtCore.binh_am_mtl.translit(@key).to_s
      jb.field "hanviet" { to_json(jb, VpDict.hanviet, 2) }
    end
  end

  def to_json(jb : JSON::Builder, dict : VpDict, type = 0)
    if term = dict.find(@key)
      add_hints(term) if type < 2

      jb.object do
        jb.field "val", term.val.first
        jb.field "ptag", term.ptag.to_str
        jb.field "rank", term.rank

        jb.field "mtime", term.mtime
        jb.field "uname", term.uname
        jb.field "state", term.state
      end
    else
      jb.object do
        if type == 2
          jb.field "val", hanviet
          jb.field "ptag", ""
        elsif type == 1 && @mt_tag.empty?
          jb.field "val", TextUtils.titleize(hanviet)
          jb.field "ptag", "nr"
        else
          jb.field "val", @mt_val
          jb.field "ptag", @mt_tag
        end

        jb.field "rank", 3
        jb.field "mtime", -1
      end
    end
  end

  getter hanviet : String do
    MtCore.hanviet_mtl.translit(@key).to_s
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
