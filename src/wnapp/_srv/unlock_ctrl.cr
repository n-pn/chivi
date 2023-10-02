require "./_wn_ctrl_base"

require "../../_data/member/unlock"

class WN::UnlockCtrl < AC::Base
  base "/_wn/unlock/:sname/:sn_id"

  @[AC::Route::PUT("/:ch_no/:p_idx")]
  def unlock(sname : String, sn_id : Int32, ch_no : Int32, p_idx : Int32)
    wstem = get_wnseed(sn_id, sname)
    cinfo = get_chinfo(wstem, ch_no)

    unlock, remain = CV::Unlock.unlock(wstem, cinfo, self._vu_id, p_idx)
    render json: ({unlock ? 1 : 0, remain})
  end
end
