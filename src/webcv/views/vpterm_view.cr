require "json"

class CV::VpTermView
  @val_hint = [] of String
  @tag_hint = [] of String

  @mtl_val : String
  @mtl_tag : String

  @hanviet : String

  def initialize(@key : String, @bdict : VpDict, cvmtl : MtCore, @uname = "~")
    mt_list = cvmtl.cv_plain(key, mode: 1, cap_first: false)
    @mtl_val = mt_list.to_s
    @mtl_tag = guess_tag(mt_list)

    @hanviet = MtCore.hanviet_mtl.translit(@key).to_s
  end

  def guess_tag(mt_list : MtList)
    # return "" if list is not singleton
    return "" unless first = mt_list.first
    first.succ? ? "" : first.tag.to_str
    # TODO guess tag by suffix
  end

  def to_json(jb : JSON::Builder)
    if f_term = VpDict.fixture.find(@key)
      c_base = c_priv = f_term
    else
      c_base, c_priv = VpDict.regular.find(@key, @uname)
    end

    u_base, u_priv = @bdict.find(@key, @uname)

    jb.object do
      @val_hint << @hanviet # add hanviet as val hint

      jb.field "binh_am", MtCore.binh_am_mtl.translit(@key).to_s
      jb.field "hanviet" { to_json(jb, VpDict.hanviet.find(@key), type: 2) }

      jb.field "u_priv" { to_json(jb, u_priv, type: 1) }
      jb.field "u_base" { to_json(jb, u_base, type: 1) }
      jb.field "c_priv" { to_json(jb, c_priv, type: 0) }
      jb.field "c_base" { to_json(jb, c_base, type: 0) }

      VpDict.suggest.find(@key).try { |x| add_hints(x, deep_loop: false) }
      jb.field "val_hint", @val_hint.push(@mtl_val).uniq.reject(&.empty?)
      jb.field "tag_hint", @tag_hint.push(@mtl_tag).uniq.reject(&.empty?)
    end
  end

  def to_json(jb : JSON::Builder, term : VpTerm?, type = 0)
    if term
      add_hints(term)

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
          jb.field "val", @hanviet
        elsif type == 1 && @mtl_tag.empty?
          jb.field "val", TextUtils.titleize(@hanviet)
          jb.field "ptag", "nr"
        else
          jb.field "val", @mtl_val
          jb.field "ptag", @mtl_tag
        end

        jb.field "mtime", -1
      end
    end
  end

  def add_hints(term : VpTerm, deep_loop = true)
    @val_hint.concat(term.val)
    @tag_hint << term.ptag.to_str
    return unless deep_loop

    while prev = term._prev
      @val_hint.concat(prev.val)
      @tag_hint << term.ptag.to_str
      term = prev
    end
  end
end
