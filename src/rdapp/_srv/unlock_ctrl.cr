require "./_ctrl_base"

class RD::UnlockCtrl < AC::Base
  base "/_rd/unlock"

  @[AC::Route::PUT("/up/:sname/:sn_id/:ch_no/:p_idx")]
  def unlock_upchap(sname : String, sn_id : Int32, ch_no : Int32, p_idx : Int32)
    ustem = get_ustem(sn_id, sname)
    cinfo = get_cinfo(ustem, ch_no)

    unlock, remain = Unlock.unlock(ustem, cinfo, self._vu_id, p_idx)
    render json: ({unlock ? 1 : 0, remain})
  end

  @[AC::Route::PUT("/wn/:sname/:wn_id/:ch_no/:p_idx")]
  def unlock_wnchap(sname : String, wn_id : Int32, ch_no : Int32, p_idx : Int32)
    wstem = get_wstem(sname, wn_id)
    cinfo = get_cinfo(wstem, ch_no)

    unlock, remain = Unlock.unlock(wstem, cinfo, self._vu_id, p_idx)
    render json: ({unlock ? 1 : 0, remain})
  end
end
