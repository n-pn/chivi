require "./_up_ctrl_base"

require "../../_data/member/unlock"

class WN::UnlockCtrl < AC::Base
  base "/_up/unlock/:sname/:up_id"

  @[AC::Route::PUT("/:ch_no/:p_idx")]
  def unlock(sname : String, up_id : Int32, ch_no : Int32, p_idx : Int32)
    ustem = get_ustem(up_id)
    cinfo = get_cinfo(ustem, ch_no)

    unlock, remain = CV::Unlock.unlock(ustem, cinfo, self._vu_id, p_idx)
    render json: ({unlock ? 1 : 0, remain})
  end
end
