require "json"

class CV::VpTermView
  @val_hint = [] of String
  @tag_hint = [] of String

  @val_tran : String
  @tag_tran : String

  alias Dicts = Tuple(VpDict, VpDict, VpDict, VpDict)

  def initialize(@key : String, @cvmtl : MtCore, @dicts : Dicts)
    mt_list = cvmtl.cv_plain(key, mode: 2, cap_mode: 0)

    @val_tran = mt_list.to_s
    @tag_tran = guess_tag(mt_list)
  end

  def guess_tag(mt_list : MtList)
    return "" unless first = mt_list.first? # return "" if list is empty
    return "" if first.succ                 # return "" if list is not singleton
    first.tag.to_str
  end

  getter hanviet : String { MtCore.hanviet_mtl.translit(@key).to_s }

  def to_json(jb : JSON::Builder)
    jb.object do
      @val_hint << hanviet # add hanviet as val hint

      jb.field "binh_am", MtCore.binh_am_mtl.translit(@key).to_s
      jb.field "hanviet" { to_json(jb, VpDict.hanviet, 2) }

      jb.field "u_priv" { to_json(jb, @dicts[0], type: 1) }
      jb.field "u_base" { to_json(jb, @dicts[1], type: 1) }
      jb.field "c_priv" { to_json(jb, @dicts[2], type: 0) }
      jb.field "c_base" { to_json(jb, @dicts[3], type: 0) }

      VpDict.suggest.find(@key).try { |x| add_hints(x, deep_loop: false) }
      jb.field "val_hint", @val_hint.push(@val_tran).uniq.reject(&.empty?)
      jb.field "tag_hint", @tag_hint.push(@tag_tran).uniq.reject(&.empty?)
    end
  end

  def to_json(jb : JSON::Builder, dict : VpDict, type = 0)
    if term = dict.find(@key)
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
          jb.field "val", hanviet
        elsif type == 1 && @tag_tran.empty?
          jb.field "val", TextUtils.titleize(hanviet)
          jb.field "ptag", "nr"
        else
          jb.field "val", @val_tran
          jb.field "ptag", @tag_tran
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
