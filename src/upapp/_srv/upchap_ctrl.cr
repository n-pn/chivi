require "./_up_ctrl_base"
require "../../_util/hash_util"
require "../../rdlib/data/chdata"
require "../../_data/member/unlock"
require "../../_data/member/xvcoin"

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
  def show(up_id : Int32, ch_no : Int32, p_idx : Int32, force : Bool = false)
    ustem = get_ustem(up_id)
    cinfo = get_cinfo(ustem, ch_no)

    plock = ustem.chap_plock(ch_no, _vu_id)
    ztext, zsize, error = read_chap(ustem, cinfo, p_idx, plock, force: force)

    output = {
      cinfo: cinfo,
      rdata: {
        fpath: cinfo.part_name(p_idx),
        plock: plock,

        zsize: zsize,
        ztext: ztext,

        _prev: ustem.clist.prev_part(ch_no, p_idx),
        _next: ustem.clist.next_part(ch_no, p_idx, cinfo.psize),
      },
      error: error,
    }

    render 200, json: output
  end

  def read_chap(ustem, cinfo, p_idx : Int32, plock : Int32, force : Bool = false)
    zsize = cinfo.sizes[p_idx]? || 0

    # TODO: recover raw text if missing?
    # TODO: download raw text if is remote
    return {[] of String, zsize, 414} if zsize == 0 || cinfo.cksum.empty?

    if _privi >= plock
      unlocked = true
    elsif _privi < 0
      unlocked = false
    else
      unlocked = CV::Unlock.unlock(ustem, cinfo, self._vu_id, p_idx, zsize: zsize, force: force)
    end

    return {[] of String, zsize, force ? 415 : 413} unless unlocked

    ztext = RD::Chdata.read_raw(cinfo.part_name(p_idx))
    {ztext, zsize, 0}
  end

  # TODO:
  # - add delete
  # - add insert
end
