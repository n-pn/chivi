require "./_wn_ctrl_base"
require "../../_util/hash_util"

class WN::ChinfoCtrl < AC::Base
  base "/_wn/chaps/:wn_id"

  @[AC::Route::GET("/:sname")]
  def index(wn_id : Int32, sname : String, pg pg_no : Int32 = 1)
    wnseed = get_wnseed(wn_id, sname)
    # TODO: restrict user access
    render json: wnseed.get_chaps(pg_no)
  end

  @[AC::Route::GET("/:sname/:ch_no")]
  def show(wn_id : Int32, sname : String, ch_no : Int32, load_mode : Int32 = 1)
    wnseed = get_wnseed(wn_id, sname)
    chinfo = get_chinfo(wnseed, ch_no)

    read_privi = wnseed.read_privi(_uname)
    read_privi &-= 1 if ch_no <= wnseed.lower_read_privi_count

    load_mode = -1 if _privi < read_privi

    ztext = Chtext.new(wnseed, chinfo)
    cksum = ztext.get_cksum!(_uname, _mode: load_mode)
    cbase = "#{wnseed.wn_id}/#{chinfo.ch_no}-#{cksum}" unless cksum.empty?

    render json: {
      cinfo: chinfo,
      rdata: {
        privi: read_privi,
        rlink: chinfo.rlink,

        sizes: chinfo.sizes,
        cbase: cbase,
      },
      _prev: wnseed.find_prev(ch_no),
      _succ: wnseed.find_succ(ch_no),
    }
  end

  @[AC::Route::GET("/:sname/:ch_no/:p_idx")]
  def show_part(wn_id : Int32, sname : String, ch_no : Int32, p_idx : Int32, rmode : Int32 = 1)
    wnseed = get_wnseed(wn_id, sname)
    chinfo = get_chinfo(wnseed, ch_no)

    plock = wnseed.read_privi(_uname)
    plock &-= 1 if ch_no <= wnseed.lower_read_privi_count

    ztext = [] of String
    status = 200

    if _privi < plock
      status = 413
    else
      chtext = Chtext.new(wnseed, chinfo)
      cksum = chtext.get_cksum!(_uname, _mode: rmode)
      if cksum.empty?
        status = 414
      else
        fpath = chtext.wn_path(p_idx, cksum)
        ztext = File.read_lines(fpath, chomp: true)
        mtime = File.info(fpath).modification_time.to_unix
      end
    end

    output = {
      cinfo: chinfo,
      rdata: {
        spath: "#{wn_id}/#{ch_no}-#{cksum}-#{p_idx}",
        plock: plock,
        rlink: chinfo.rlink,

        mtime: mtime,
        zsize: chinfo.sizes[p_idx],
        ztext: ztext,

        _curr: p_idx > 1 ? "#{ch_no}_#{p_idx}" : ch_no.to_s,
        _prev: prev_href(wnseed, chinfo, p_idx),
        _succ: succ_href(wnseed, chinfo, p_idx),
      },

    }

    render status, json: output
  end

  private def prev_href(stem, chap, part)
    return "#{chap.ch_no}_#{part &- 1}" if part > 1
    return "" unless (chap.ch_no > 1) && (prev_chap = stem.find_prev(chap.ch_no))

    prev_size = prev_chap.psize
    prev_size > 1 ? "#{prev_chap.ch_no}-#{prev_size}" : prev_chap.ch_no.to_s
  end

  private def succ_href(stem, chap, part)
    return "#{chap.ch_no}_#{part &+ 1}" if part < chap.psize
    return "" if chap.ch_no >= stem.chap_total
    stem.find_succ(chap.ch_no).try(&.ch_no.to_s) || ""
  end
end
