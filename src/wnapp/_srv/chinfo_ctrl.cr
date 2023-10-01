require "./_wn_ctrl_base"
require "../../_util/hash_util"

class WN::ChinfoCtrl < AC::Base
  base "/_wn/chaps/:wn_id"

  @[AC::Route::GET("/:sname")]
  def index(wn_id : Int32, sname : String, pg pg_no : Int32 = 1)
    wseed = get_wnseed(wn_id, sname)
    # TODO: restrict user access
    render json: wseed.get_chaps(pg_no)
  end

  @[AC::Route::GET("/:sname/:ch_no/:p_idx")]
  def show_part(wn_id : Int32, sname : String, ch_no : Int32, p_idx : Int32, rmode : Int32 = 1)
    wseed = get_wnseed(wn_id, sname)
    cinfo = get_chinfo(wseed, ch_no)

    plock = wseed.chap_plock(ch_no)
    ztext, zsize, error = read_chap(ustem, cinfo, p_idx, plock, force: force)

    if _privi < plock
      error = 413
    else
      chtext = Chtext.new(wseed, cinfo)
      cksum = chtext.get_cksum!(_uname, _mode: rmode) rescue ""

      if cksum.empty?
        error = 414
      else
        fpath = chtext.wn_path(p_idx, cksum)
        ztext = File.read_lines(fpath, chomp: true)
      end
    end

    output = {
      cinfo: cinfo,
      rdata: {
        fpath: cinfo.part_name,
        plock: plock,

        zsize: cinfo.sizes[p_idx]? || 0,
        ztext: ztext,

        _prev: p_idx > 1 ? chap.part_href(p_idx &- 1) : wstem.find_prev(ch_no).try(&.part_href(-1)),
        _succ: p_idx < chap.psize ? chap.part_href(p_idx &+ 1) : wstem.find_succ(ch_no).try(&.part_href(1)),
      },
      error: error,
    }

    render 200, json: output
  end

  def read_chap(wstem, cinfo, p_idx : Int32, plock : Int32, force : Bool = false)
    zsize = cinfo.sizes[p_idx]? || 0

    # TODO: recover raw text if missing?
    # TODO: download raw text if is remote
    return {[] of String, zsize, 414} if zsize == 0 || cinfo.cksum.empty?

    if _privi >= plock
      unlocked = true
    elsif _privi < 0
      unlocked = false
    else
      unlocked = CV::Unlock.unlock(self._vu_id, zsize, wstem, cinfo, p_idx, force: force)
    end

    return {[] of String, zsize, 415} unless unlocked

    fpath = cinfo.file_path(p_idx: p_idx, ftype: "raw.txt")

    ztext = File.read_lines(fpath, chomp: true)
    ztext.unshift(cinfo.ztitle) unless ztext.first == cinfo.ztitle

    {ztext, zsize, 0}
  end
end
