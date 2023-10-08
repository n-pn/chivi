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
  def wn_cpart(sname : String, sn_id : Int32, ch_no : Int32, p_idx : Int32, force : Bool = false)
    wstem = get_wstem(sname, sn_id)
    cinfo = get_cinfo(wstem, ch_no)

    if cinfo.cksum.empty? && _privi >= 0 && !cinfo.rlink.empty?
      wstem.crepo.save_raw_from_link!(cinfo, _uname, force: force)
    end

    rdata = wstem.crepo.part_data(cinfo, p_idx, vu_id: _vu_id, privi: _privi)
    render 200, json: rdata
  end

  @[AC::Route::GET("/rm/:sname/:sn_id/:ch_no/:p_idx")]
  def rm_cpart(sname : String, sn_id : String, ch_no : Int32, p_idx : Int32, force : Bool = false)
    crepo = get_rstem(sname, sn_id).crepo
    cinfo = get_cinfo(crepo, ch_no)

    if cinfo.cksum.empty? && _privi >= 0 && !cinfo.rlink.empty?
      crepo.save_raw_from_link!(cinfo, _uname, force: force)
    end

    rdata = crepo.part_data(cinfo, p_idx, vu_id: _vu_id, privi: _privi)
    render 200, json: rdata
  end

  @[AC::Route::GET("/up/:sname/:sn_id/:ch_no/:p_idx")]
  def up_cpart(sname : String, sn_id : Int32, ch_no : Int32, p_idx : Int32)
    ustem = get_ustem(sn_id, sname)
    spawn ustem.inc_view_count!

    cinfo = get_cinfo(ustem, ch_no)

    vu_id = self._vu_id
    privi = vu_id == ustem.owner ? 5 : _privi

    rdata = ustem.crepo.part_data(cinfo, p_idx, vu_id: vu_id, privi: privi)
    render 200, json: rdata
  end
end
