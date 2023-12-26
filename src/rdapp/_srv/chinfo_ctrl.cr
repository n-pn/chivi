require "./_ctrl_base"

class RD::ChinfoCtrl < AC::Base
  base "/_rd/chaps"

  @[AC::Route::GET("/:sname/:sn_id")]
  def index(sname : String, sn_id : Int32, _last : Bool = false)
    crepo = Tsrepo.load!("#{sname}/#{sn_id}")
    _pg_no, limit, offset = _paginate(min: 32, max: 64)

    if _last
      chaps = crepo.get_top(start: crepo.chmax &- offset, limit: limit)
    else
      chaps = crepo.get_all(start: offset, limit: limit)
    end

    render json: chaps
  end

  ###########

  @[AC::Route::GET("/:sname/:sn_id/:ch_no/:p_idx")]
  def show_path(sname : String, sn_id : String, ch_no : Int32, p_idx : Int32,
                force : Bool = false, regen : Bool = false)
    crepo = Tsrepo.load!("#{sname}/#{sn_id}")
    cinfo = get_cinfo(crepo, ch_no)
    ztext, cksum, error, ulkey, multp = build_cpart(crepo, cinfo, p_idx, force, regen)
    spawn { inc_view_count!(crepo, crepo.sname) } if error == 0

    json = {
      ch_no: cinfo.ch_no,
      p_max: cinfo.psize,
      p_idx: p_idx,

      title: cinfo.vtitle,
      chdiv: cinfo.vchdiv,
      rlink: cinfo.rlink,

      error: error,
      plock: crepo.read_privi,

      fpath: ulkey,
      ztext: error > 0 ? "" : ztext,

      multp: multp,
      mtime: cinfo.mtime,
      uname: cinfo.uname,

      _prev: prev_part(crepo, cinfo.ch_no, p_idx),
      _next: next_part(crepo, cinfo.ch_no, p_idx, cinfo.psize),
    }

    render 200, json: json
  end

  private def build_cpart(crepo, cinfo, p_idx, force, regen)
    vu_id, privi = self._vu_id, self._privi
    user_multp, real_multp = crepo.chap_mutlp(cinfo.ch_no, vu_id: vu_id, privi: privi)

    ztext, cksum = crepo.load_raw_part(cinfo, p_idx, regen: regen)

    if cinfo.cksum.empty?
      ulkey = "#{crepo.sname}/#{crepo.sn_id}/#{cksum.to_s(32)}"
    else
      ulkey = "#{crepo.sroot}/#{cinfo.ch_no}-#{cinfo.cksum}-#{p_idx}"
    end

    if privi < crepo.read_privi
      error = 403
    elsif cksum == 0
      error = 414
    elsif real_multp < 1 || Unlock.unlocked?(vu_id, ulkey, cksum.unsafe_as(Int32))
      error = 0
    elsif force || user_multp == 0
      error = Unlock.new(
        vu_id: vu_id, ulkey: ulkey,
        owner: crepo.owner, zsize: ztext.size,
        cksum: cksum.unsafe_as(Int32),
        user_multp: user_multp, real_multp: real_multp,
      ).unlock!
    else
      error = 413
    end

    {ztext, cksum, error, error > 0 ? "" : ulkey, user_multp}
  end

  private def prev_part(crepo, ch_no, p_idx)
    return "#{ch_no}_#{p_idx &- 1}" if p_idx > 1
    return "" unless pchap = Chinfo.find_prev(crepo.info_db, ch_no)
    psize = pchap.psize
    psize > 1 ? "#{pchap.ch_no}_#{psize}" : pchap.ch_no.to_s
  end

  private def next_part(crepo, ch_no : Int32, p_idx : Int32, psize : Int32)
    return "#{ch_no}_#{p_idx &+ 1}" if p_idx < psize
    Chinfo.find_next(crepo.info_db, ch_no).try(&.ch_no).to_s
  end

  private def inc_view_count!(crepo : Tsrepo, sname : String)
    value = (self._privi &+ 2)
    crepo.inc_view_count!(value)
    case crepo.stype
    when 1
      get_ustem(crepo.sn_id, sname).inc_view_count!(value)
    when 2
      get_rstem(sname, crepo.sn_id).inc_view_count!(value)
    end
  end
end
