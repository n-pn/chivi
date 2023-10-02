require "./_up_ctrl_base"
require "../../_util/hash_util"

require "../../rdlib/data/chdata"
require "../../_data/member/unlock"

class UP::UpchapCtrl < AC::Base
  base "/_up/chaps/:up_id"

  @[AC::Route::GET("/")]
  def index(up_id : Int32)
    # TODO: restrict user access?
    ustem = get_ustem(up_id)
    _pg_no, limit, offset = _paginate(min: 32, max: 64)
    chaps = ustem.get_chaps(chmin: offset, limit: limit)

    render json: chaps
  end

  @[AC::Route::GET("/:ch_no/:p_idx")]
  def show(up_id : Int32, ch_no : Int32, p_idx : Int32)
    ustem = get_ustem(up_id)
    cinfo = get_cinfo(ustem, ch_no)

    plock = ustem.chap_plock(ch_no, _vu_id)
    ztext, error = read_chap(ustem, cinfo, p_idx, plock)

    rdata = {
      ch_no: ch_no,
      p_idx: p_idx,
      p_max: cinfo.psize,

      title: cinfo.vtitle.empty? ? cinfo.ztitle : cinfo.vtitle,
      chdiv: cinfo.vchdiv.empty? ? cinfo.zchdiv : cinfo.vchdiv,

      rlink: cinfo.rlink,
      fpath: cinfo.part_name(p_idx),

      ztext: ztext,
      error: error,
      zsize: cinfo.sizes[p_idx]? || 0,

      plock: plock,
      mtime: cinfo.mtime,
      uname: cinfo.uname,

      _prev: ustem.clist.prev_part(ch_no, p_idx),
      _next: ustem.clist.next_part(ch_no, p_idx, cinfo.psize),
    }

    render 200, json: rdata
  end

  def read_chap(ustem, cinfo, p_idx : Int32, plock : Int32)
    return {[] of String, 414} if cinfo.cksum.empty?
    zsize = cinfo.sizes[p_idx]? || 0

    ulkey = cinfo.part_name(p_idx)
    can_read = _privi >= plock || CV::Unlock.unlocked?(self._vu_id, ulkey)

    can_read ? {RD::Chdata.read_raw(ulkey), 0} : {[] of String, 413}
  end

  # TODO:
  # - add delete
  # - add insert
end
