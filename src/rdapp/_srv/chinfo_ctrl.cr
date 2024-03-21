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
    zdata, error, multp = load_chap(crepo, cinfo, force, regen)
    spawn { inc_view_count!(crepo, crepo.sname) } if error == 0

    json = {
      ch_no: cinfo.ch_no,
      title: cinfo.title,
      chdiv: cinfo.chdiv,

      ztext: error > 0 || zdata.zsize == 0 ? zdata.title : zdata.cbody,
      zsize: zdata.zsize,
      cksum: "#{zdata.ch_no}-#{zdata.mtime}",

      error: error,
      plock: crepo.read_privi(cinfo.ch_no),
      multp: multp,

      mtime: cinfo.mtime,
      uname: cinfo.uname,
      rlink: cinfo.zlink,
    }

    render 200, json: json
  rescue ex
    Log.error(exception: ex) { ex.message }
    render 500, text: ex.message
  end

  private def load_chap(crepo, cinfo, force, regen)
    vu_id, privi = self._vu_id, self._privi
    zdata = crepo.get_zdata(cinfo.ch_no, regen ? 2 : 1)

    user_cost, owner_got = crepo.mt_multp(cinfo.ch_no, vu_id, privi)

    ulkey = "#{crepo.sroot}/#{cinfo.ch_no}"

    if privi < crepo.read_privi(cinfo.ch_no)
      error = 403
    elsif zdata.zsize == 0
      error = 414
    elsif user_cost == 0 || Unlock.unlocked?(vu_id, ulkey)
      error = 0
    elsif force
      error = Unlock.new(
        vu_id: vu_id, ulkey: ulkey,
        owner: crepo.owner, zsize: zdata.zsize,
        user_multp: user_cost, real_multp: owner_got,
      ).unlock!
    else
      error = 413
    end

    {zdata, error, user_cost}
  end

  private def inc_view_count!(crepo : Tsrepo, sname : String)
    value = self._privi &+ 2
    crepo.inc_view_count!(value)

    case crepo.stype
    when 1
      get_ustem(crepo.sn_id, sname).inc_view_count!(value)
    when 2
      get_rstem(sname, crepo.sn_id).inc_view_count!(value)
    end
  end
end
