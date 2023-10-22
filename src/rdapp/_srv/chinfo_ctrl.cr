require "./_ctrl_base"

class RD::ChinfoCtrl < AC::Base
  base "/_rd/chaps"

  @[AC::Route::GET("/wn/:sname/:sn_id")]
  def wn_clist(sname : String, sn_id : Int32, _last : Bool = false)
    wstem = get_wstem(sname, sn_id)
    get_chaps(wstem.crepo, _last: _last)
  end

  @[AC::Route::GET("/rm/:sname/:sn_id")]
  def rm_clist(sname : String, sn_id : String, _last : Bool = false)
    rstem = get_rstem(sname, sn_id)
    get_chaps(rstem.crepo, _last: _last)
  end

  @[AC::Route::GET("/up/:sname/:sn_id")]
  def up_clist(sname : String, sn_id : Int32, _last : Bool = false)
    ustem = get_ustem(sn_id, sname)
    get_chaps(ustem.crepo, _last: _last)
  end

  private def get_chaps(crepo : Chrepo, _last : Bool = false)
    _pg_no, limit, offset = _paginate(min: 32, max: 64)

    if _last
      chaps = crepo.get_top(start: crepo.chmax &- offset, limit: limit)
    else
      chaps = crepo.get_all(start: offset, limit: limit)
    end

    render json: chaps
  end

  ###########

  @[AC::Route::GET("/wn/:sname/:sn_id/:ch_no/:p_idx")]
  def wn_cpart(sname : String, sn_id : Int32,
               ch_no : Int32, p_idx : Int32,
               force : Bool = false, regen : Bool = false)
    crepo = get_wstem(sname, sn_id).crepo
    cinfo = get_cinfo(crepo, ch_no)

    crepo.save_raw_from_link!(cinfo, _uname, force: regen) if _privi >= 0
    rdata = show_part(crepo: crepo, cinfo: cinfo, p_idx: p_idx, force: force)

    render 200, json: rdata
  end

  @[AC::Route::GET("/rm/:sname/:sn_id/:ch_no/:p_idx")]
  def rm_cpart(sname : String, sn_id : String,
               ch_no : Int32, p_idx : Int32,
               force : Bool = false, regen : Bool = false)
    rstem = get_rstem(sname, sn_id)
    cinfo = get_cinfo(rstem, ch_no)

    rstem.crepo.save_raw_from_link!(cinfo, _uname, force: regen) if _privi >= 0
    rdata = show_part(crepo: rstem.crepo, cinfo: cinfo, p_idx: p_idx, force: force)

    spawn { rstem.inc_view_count!(self._privi &+ 2) } if rdata[:error] < 300

    render 200, json: rdata
  end

  @[AC::Route::GET("/up/:sname/:sn_id/:ch_no/:p_idx")]
  def up_cpart(sname : String, sn_id : Int32,
               ch_no : Int32, p_idx : Int32,
               force : Bool = false, regen : Bool = false)
    ustem = get_ustem(sn_id, sname)

    cinfo = get_cinfo(ustem, ch_no)
    rdata = show_part(crepo: ustem.crepo, cinfo: cinfo, p_idx: p_idx, force: force)

    spawn { ustem.inc_view_count!(self._privi &+ 2) } if rdata[:error] < 300
    render 200, json: rdata
  end

  private def show_part(crepo : Chrepo, cinfo : Chinfo, p_idx : Int32,
                        force : Bool = false)
    vu_id = self._vu_id
    privi = self._privi
    ch_no = cinfo.ch_no

    user_multp, real_multp = crepo.chap_mutlp(ch_no, vu_id: vu_id, privi: privi)

    fpath = crepo.part_name(cinfo, p_idx)
    zsize = cinfo.sizes[p_idx]? || 0

    if zsize == 0 || cinfo.cksum.empty?
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

    {
      ch_no: cinfo.ch_no,
      p_max: cinfo.psize,
      p_idx: p_idx,

      zname: cinfo.ztitle,
      rlink: cinfo.rlink,

      title: cinfo.vtitle.empty? ? cinfo.ztitle : cinfo.vtitle,
      chdiv: cinfo.vchdiv.empty? ? cinfo.zchdiv : cinfo.vchdiv,
      error: error,

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
