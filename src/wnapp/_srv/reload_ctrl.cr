require "./_wn_ctrl_base"

require "../../_util/hash_util"

class WN::ReloadCtrl < AC::Base
  base "/_wn/reload/:sname/:sn_id"

  @[AC::Route::PUT("/:ch_no")]
  def reload_chap(sname : String, sn_id : Int32, ch_no : Int32)
    wstem = get_wnseed(sn_id, sname)
    cinfo = get_chinfo(wstem, ch_no)

    plock = wstem.chap_plock(ch_no)

    if _privi < plock
      render 403, text: "cần quyền hạn #{plock} để tải lại nguồn"
      return
    end

    # if cinfo.rlink.empty?
    ctext = Chtext.new(wstem, cinfo)
    cksum = ctext.load_from_remote!(_uname, force: true) rescue ""

    if cksum && !cksum.empty?
      render 201, text: cksum
    else
      render 500, text: "không tải lại được text gốc của chương"
    end
  end
end
