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
    return "" unless (first = mt_list.first) && first.body?

    case tag = first.tag.to_str
    when "np" then "n"
    when "ap" then "a"
    when "vp" then "vf"
    else           tag
    end
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
      jb.field "hanviet" { to_json(jb, VpDict.hanviet, dtype: 2) }
      jb.field "regular" { to_json(jb, VpDict.regular, dtype: 1) }
      jb.field "special" { to_json(jb, @bdict, dtype: 0) }

      VpDict.suggest.find(@key).try { |x| add_hints(x, deep_loop: false) }
      jb.field "val_hint", @val_hint.push(@mtl_val).uniq.reject(&.empty?)
      jb.field "tag_hint", @tag_hint.push(@mtl_tag).uniq.reject(&.empty?)
    end
  end

  def to_json(jb : JSON::Builder, vdict : VpDict, dtype = 0)
    b_term, u_term = vdict.find(@key, @uname)

    if dtype == 0 && (f_term = VpDict.fixture.find(@key))
      b_term, u_term = f_term, nil
    else
      b_term, u_term = vdict.find(@key, @uname)
    end

    jb.object do
      case dtype
      when 2 # hanviet
        jb.field "u_privi", 4
        jb.field "b_privi", 3
      when 1 # regular
        jb.field "u_privi", 0
        jb.field "b_privi", 1
      when 0 # special
        jb.field "u_privi", 1
        jb.field "b_privi", 2
      end

      if u_term
        add_hints(u_term)

        jb.field "u_val", u_term.val.first
        jb.field "u_ptag", u_term.ptag.to_str
        jb.field "u_rank", u_term.rank

        jb.field "u_mtime", u_term.mtime
        # jb.field "u_uname", u_term.uname
        jb.field "u_state", u_term.state
      end

      if b_term
        add_hints(b_term)

        jb.field "b_val", b_term.val.first
        jb.field "b_ptag", b_term.ptag.to_str
        jb.field "b_rank", b_term.rank

        jb.field "b_mtime", b_term.mtime
        jb.field "b_uname", b_term.uname
        jb.field "b_state", b_term.state
      end

      if dtype == 2
        jb.field "h_val", @hanviet
      elsif dtype == 0 && @mtl_tag.empty?
        jb.field "h_val", TextUtils.titleize(@hanviet)
        jb.field "h_ptag", "nr"
      else
        jb.field "h_val", @mtl_val
        jb.field "h_ptag", @mtl_tag
      end
    end

    # b_term.try{|x| }
    # if term
    #   add_hints(term)

    #   jb.object do
    #     jb.field "val", term.val.first
    #     jb.field "ptag", term.ptag.to_str
    #     jb.field "rank", term.rank

    #     jb.field "mtime", term.mtime
    #     jb.field "uname", term.uname
    #     jb.field "state", term.state
    #   end
    # else
    #   jb.object do
    #     if type == 2
    #       jb.field "val", @hanviet
    #     elsif type == 1 && @mtl_tag.empty?
    #       jb.field "val", TextUtils.titleize(@hanviet)
    #       jb.field "ptag", "nr"
    #     else
    #       jb.field "val", @mtl_val
    #       jb.field "ptag", @mtl_tag
    #     end

    #     jb.field "mtime", -1
    #   end
    # end
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
