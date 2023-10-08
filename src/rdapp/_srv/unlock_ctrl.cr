require "./_ctrl_base"

class RD::UnlockCtrl < AC::Base
  base "/_rd/unlock"

  @[AC::Route::PUT("/up/:sname/:sn_id/:ch_no/:p_idx")]
  def unlock_upchap(sname : String, sn_id : Int32, ch_no : Int32, p_idx : Int32)
    ustem = get_ustem(sn_id, sname)
    multp = ustem.multp

    crepo = ustem.crepo
    cinfo = get_cinfo(crepo, ch_no)

    entry = Unlock.new(crepo, cinfo, self._vu_id, p_idx, multp: multp, owner: ustem.owner)
    unlock, remain = entry.unlock

    render json: ({unlock ? 1 : 0, remain})
  end

  @[AC::Route::PUT("/wn/:sname/:sn_id/:ch_no/:p_idx")]
  def unlock_wnchap(sname : String, sn_id : Int32, ch_no : Int32, p_idx : Int32)
    wstem = get_wstem(sname, sn_id)
    multp = wstem.privi &* 2_i16 &- 1_i16

    crepo = wstem.crepo
    cinfo = get_cinfo(crepo, ch_no)

    entry = Unlock.new(crepo, cinfo, self._vu_id, p_idx, multp: multp)
    unlock, remain = entry.unlock

    render json: ({unlock ? 1 : 0, remain})
  end

  @[AC::Route::PUT("/rm/:sname/:sn_id/:ch_no/:p_idx")]
  def unlock_rmchap(sname : String, sn_id : String, ch_no : Int32, p_idx : Int32)
    rstem = get_rstem(sname, sn_id)
    multp = 3_i16

    crepo = rstem.crepo
    cinfo = get_cinfo(crepo, ch_no)

    entry = Unlock.new(crepo, cinfo, self._vu_id, p_idx, multp: multp)

    unlock, remain = entry.unlock
    render json: ({unlock ? 1 : 0, remain})
  end
end
