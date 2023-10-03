require "./_wn_ctrl_base"

require "../../_util/hash_util"
require "../../_data/member/unlock"

class WN::ChinfoCtrl < AC::Base
  base "/_wn/chaps/:wn_id"

  @[AC::Route::GET("/:sname")]
  def index(wn_id : Int32, sname : String, pg pg_no : Int32 = 1)
    wstem = get_wnseed(wn_id, sname)
    # TODO: restrict user access
    render json: wstem.get_chaps(pg_no)
  end

  @[AC::Route::GET("/:sname/:ch_no/:p_idx")]
  def show(wn_id : Int32, sname : String, ch_no : Int32, p_idx : Int32)
    wstem = get_wnseed(wn_id, sname)
    cinfo = get_chinfo(wstem, ch_no)

    plock = wstem.chap_plock(ch_no)
    # plock = 5

    ztext, error = read_chap(wstem, cinfo, p_idx, plock)

    rdata = {
      ch_no: ch_no,
      p_idx: p_idx,
      p_max: cinfo.psize,

      title: cinfo.vtitle.empty? ? cinfo.ztitle : cinfo.vtitle,
      chdiv: cinfo.vchdiv.empty? ? cinfo.zchdiv : cinfo.vchdiv,

      rlink: cinfo.rlink,
      fpath: cinfo.part_name(wn_id, p_idx),

      plock: plock,
      mtime: cinfo.mtime,
      uname: cinfo.uname,

      ztext: ztext,
      error: error,
      zsize: cinfo.sizes[p_idx]? || 0,

      _prev: wstem.prev_href(cinfo, p_idx),
      _next: wstem.next_href(cinfo, p_idx),
    }

    render 200, json: rdata
  end

  def read_chap(wstem, cinfo, p_idx : Int32, plock : Int32)
    ctext = Chtext.new(wstem, cinfo)

    cksum = ctext.get_cksum!(_uname, _mode: 1)
    return {[cinfo.ztitle], 414} if cksum.empty?

    ulkey = cinfo.part_name(wstem.wn_id, p_idx)

    can_read = _privi >= plock || CV::Unlock.unlocked?(self._vu_id, ulkey)
    can_read ? {ctext.load_raw!(p_idx), 0} : {[cinfo.ztitle] of String, 413}
  end

  @[AC::Route::GET("/:sname/:ch_no")]
  def reload(wn_id : Int32, sname : String, ch_no : Int32)
    wstem = get_wnseed(wn_id, sname)
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
