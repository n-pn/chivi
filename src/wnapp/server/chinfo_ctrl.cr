require "./_wn_ctrl_base"
require "../../_util/hash_util"

class WN::ChinfoCtrl < AC::Base
  base "/_wn/chaps"

  @[AC::Route::GET("/:wn_id/:sname")]
  def index(wn_id : Int32, sname : String, pg pg_no : Int32 = 1)
    wnseed = get_wnseed(wn_id, sname)
    # TODO: restrict user access
    render json: wnseed.get_chaps(pg_no)
  end

  @[AC::Route::GET("/:wn_id/:sname/:ch_no")]
  def show(wn_id : Int32, sname : String, ch_no : Int32, load_mode : Int32 = 1)
    wnseed = get_wnseed(wn_id, sname)
    chinfo = get_chinfo(wnseed, ch_no)

    read_privi = wnseed.read_privi(_uname)
    read_privi &-= 1 if ch_no <= wnseed.lower_read_privi_count

    load_mode = -1 if _privi < read_privi

    ztext = Zctext.new(wnseed, chinfo)
    cksum = ztext.get_cksum!(_uname, _mode: load_mode)

    render json: {
      chinfo: chinfo,
      chdata: {
        privi: read_privi,
        rlink: chinfo.rlink,
        sizes: chinfo.sizes,
        cbase: ztext.cbase,
        cksum: cksum,
        _prev: wnseed.find_prev(ch_no).try(&._href(-1)),
        _next: wnseed.find_succ(ch_no).try(&._href(1)),
      },
    }
  end
end
