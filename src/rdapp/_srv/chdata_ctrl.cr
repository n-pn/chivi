require "./_ctrl_base"

class RD::ChdataCtrl < AC::Base
  base "/_rd/cdata"

  @[AC::Route::GET("/wn/:sname/:sn_id/:ch_no/:p_idx")]
  def wn_cdata(sname : String, sn_id : Int32,
               ch_no : Int32, p_idx : Int32,
               force : Bool = false, regen : Bool = false)
    crepo = get_wstem(sname, sn_id).crepo
    cinfo = get_cinfo(crepo, ch_no)

    if _privi >= 0
      crepo.save_raw_from_link!(cinfo, _uname, force: regen)
    end

    rdata = show_part(crepo: crepo, cinfo: cinfo, p_idx: p_idx, force: force)
    render 200, json: rdata
  end

  @[AC::Route::GET("/rm/:sname/:sn_id/:ch_no/:p_idx")]
  def rm_cdata(sname : String, sn_id : String,
               ch_no : Int32, p_idx : Int32,
               force : Bool = false, regen : Bool = false)
    rstem = get_rstem(sname, sn_id)
    cinfo = get_cinfo(rstem, ch_no)

    if _privi >= 0
      rstem.crepo.save_raw_from_link!(cinfo, _uname, force: regen)
    end

    rdata = show_part(crepo: rstem.crepo, cinfo: cinfo, p_idx: p_idx, force: force)
    render 200, json: rdata
  end

  @[AC::Route::GET("/up/:sname/:sn_id/:ch_no/:p_idx")]
  def up_cdata(sname : String, sn_id : Int32,
               ch_no : Int32, p_idx : Int32,
               force : Bool = false, regen : Bool = false)
    ustem = get_ustem(sn_id, sname)
    cinfo = get_cinfo(ustem, ch_no)

    rdata = show_part(crepo: ustem.crepo, cinfo: cinfo, p_idx: p_idx, force: force)
    render 200, json: rdata
  end

  private def show_part(crepo : Chrepo, cinfo : Chinfo, p_idx : Int32 = 1, force : Bool = false)
    sleep (2 ** (5 - self._privi) * 10).milliseconds

    vu_id = self._vu_id
    # plock = chap_plock(cinfo.ch_no)

    multp = crepo.chap_mutlp(cinfo.ch_no, vu_id: vu_id, privi: self._privi)
    fpath, zsize, error = crepo.grant_chap(cinfo, p_idx, multp, vu_id: vu_id, force: force)
    fpath = "" if error > 0
    {
      p_max: cinfo.psize,
      p_idx: p_idx,

      zname: cinfo.ztitle,

      fpath: fpath,
      error: error,
      ztext: fpath.empty? ? [] of String : Chpart.read_raw(fpath),
    }
  end
end
