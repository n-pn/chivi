require "./_ctrl_base"

class RD::ChinfoCtrl < AC::Base
  base "/_rd/chaps"

  @[AC::Route::GET("/:sname/:sn_id")]
  def index(sname : String, sn_id : Int32, _last : Bool = false)
    crepo = Tsrepo.load!("#{sname}/#{sn_id}")
    _pg_no, limit, offset = _paginate(min: 32, max: 64)

    if _last
      chaps = crepo.get_top(start: crepo.chmax &- offset, limit: limit)
    else
      chaps = crepo.get_all(start: offset, limit: limit)
    end

    render json: chaps
  end

  ###########

  @[AC::Route::GET("/:sname/:sn_id/:ch_no")]
  def show(sname : String, sn_id : String, ch_no : Int32, force : Bool = false, regen : Bool = false)
    crepo = Tsrepo.load!("#{sname}/#{sn_id}")
    cinfo = get_cinfo(crepo, ch_no)
    ztext, cksum, error = load_chap(crepo, cinfo, force, regen)
    spawn { inc_view_count!(crepo, crepo.sname) } if error == 0

    json = {
      ch_no: cinfo.ch_no,
      title: cinfo.vchdiv.empty? ? cinfo.vtitle : "#{cinfo.vtitle} - #{cinfo.vchdiv}",

      ztext: error > 0 ? "" : ztext,
      zsize: ztext.size,
      cksum: cksum,

      error: error,
      plock: crepo.read_privi,

      rlink: cinfo.rlink,
      mtime: cinfo.mtime,
      uname: cinfo.uname,
    }

    render 200, json: json
  rescue ex
    Log.error(exception: ex) { ex.message }
    render 500, text: ex.message
  end

  private def load_chap(crepo, cinfo, force, regen)
    vu_id, privi = self._vu_id, self._privi
    multp = vu_id == crepo.owner || cinfo.ch_no < crepo.free_until ? 0_i16 : 1_i16

    ztext, cksum = crepo.load_ztext(cinfo, regen: regen)
    ulkey = "#{crepo.sroot}/#{cinfo.ch_no}"

    if privi < crepo.read_privi
      error = 403
    elsif cksum == 0
      error = 414
    elsif multp == 0 || Unlock.unlocked?(vu_id, ulkey, cksum.unsafe_as(Int32))
      error = 0
    elsif force
      error = Unlock.new(
        vu_id: vu_id, ulkey: ulkey,
        owner: crepo.owner, zsize: ztext.size,
        cksum: cksum.unsafe_as(Int32),
        user_multp: multp, real_multp: multp,
      ).unlock!
    else
      error = 413
    end

    {ztext, cksum, error}
  end

  private def inc_view_count!(crepo : Tsrepo, sname : String)
    value = (self._privi &+ 1)
    crepo.inc_view_count!(value)
    case crepo.stype
    when 1
      get_ustem(crepo.sn_id, sname).inc_view_count!(value)
    when 2
      get_rstem(sname, crepo.sn_id).inc_view_count!(value)
    end
  end
end
