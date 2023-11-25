require "./_ctrl_base"

class RD::ChinfoCtrl < AC::Base
  base "/_rd/chaps"

  @[AC::Route::GET("/:sname/:sn_id")]
  def index(sname : String, sn_id : Int32, _last : Bool = false)
    crepo = Chrepo.load!("#{sname}/#{sn_id}")

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
    crepo = Chrepo.load!("#{sname}/#{sn_id}")
    cinfo = get_cinfo(crepo, ch_no)

    crepo.save_raw_from_link!(cinfo, _uname, force: regen) if _privi >= 0
    rdata = show_part(crepo: crepo, cinfo: cinfo, p_idx: p_idx, force: force)
    spawn inc_view_count!(crepo, sname[2..]) if rdata[:error] < 300

    render 200, json: rdata
  end

  private def inc_view_count!(crepo : Chrepo, sname : String)
    value = (self._privi &+ 2)
    crepo.inc_view_count!(value)
    case crepo.stype
    when 1
      get_ustem(crepo.sn_id, sname).inc_view_count!(value)
    when 2
      get_rstem(sname, crepo.sn_id.to_s).inc_view_count!(value)
    end
  end

  private def show_part(crepo : Chrepo, cinfo : Chinfo, p_idx : Int32,
                        force : Bool = false)
    vu_id = self._vu_id
    privi = self._privi
    ch_no = cinfo.ch_no

    user_multp, real_multp = crepo.chap_mutlp(ch_no, vu_id: vu_id, privi: privi)

    fpath = crepo.part_name(cinfo, p_idx)
    zsize = cinfo.sizes[p_idx]? || 0

    if privi < crepo.plock
      error = 403
    elsif zsize == 0 || cinfo.cksum.empty?
      error = 414
    elsif real_multp < 1 || Unlock.unlocked?(vu_id, fpath)
      error = 0
    elsif force || user_multp == 0
      error = Unlock.new(
        vu_id: vu_id, ulkey: fpath,
        owner: crepo.owner, zsize: zsize,
        user_multp: user_multp, real_multp: real_multp,
      ).unlock!
    else
      error = 413
    end

    fpath = "" if error > 0
    ztext = fpath.empty? ? [] of String : Chpart.read_raw(fpath)
    ztext.map!(&.gsub('　', ""))

    {
      ch_no: cinfo.ch_no,
      p_max: cinfo.psize,
      p_idx: p_idx,

      zname: cinfo.ztitle,
      rlink: cinfo.rlink,

      title: cinfo.vtitle.empty? ? cinfo.ztitle : cinfo.vtitle,
      chdiv: cinfo.vchdiv.empty? ? cinfo.zchdiv : cinfo.vchdiv,

      error: error,
      plock: crepo.plock,

      fpath: fpath,
      ztext: ztext,
      zsize: zsize,

      multp: user_multp,
      mtime: cinfo.mtime,
      uname: cinfo.uname,

      _prev: crepo.prev_part(cinfo.ch_no, p_idx),
      _next: crepo.next_part(cinfo.ch_no, p_idx, cinfo.psize),
    }
  end
end
