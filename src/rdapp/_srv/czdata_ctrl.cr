require "./_ctrl_base"
require "./czdata_form"

class RD::CzdataCtrl < AC::Base
  base "/_rd/czdatas"

  @[AC::Route::GET("/:sname/:sn_id/:ch_no")]
  def get_ztext(sname : String, sn_id : Int32, ch_no : Int32)
    crepo = Chrepo.load!("#{sname}/#{sn_id}")

    owner = crepo.owner >= 0 ? crepo.owner : self._vu_id
    guard_owner owner, crepo.plock, "truy cập text gốc của chương"

    if cinfo = crepo.find(ch_no)
      json = {ztext: crepo.load_raw!(cinfo), title: cinfo.ztitle, chdiv: cinfo.zchdiv}
    else
      json = {ztext: "", title: "", chdiv: crepo.get_chdiv(ch_no)}
    end

    render json: json
  end

  @[AC::Route::POST("/:sname/:sn_id", body: :clist)]
  def upsert(sname : String, sn_id : Int32, clist : Array(ZcdataForm))
    raise "Bạn chỉ được đăng tải nhiều nhất 64 chương một lúc!" if clist.size > 64

    crepo = Chrepo.load!("#{sname}/#{sn_id}")
    owner = crepo.owner >= 0 ? crepo.owner : self._vu_id
    guard_owner owner, crepo.plock, "thêm text gốc cho nguồn truyện"

    crepo.mkdirs!
    clist.each(&.save!(crepo: crepo, uname: self._uname))

    chmin, chmax = clist.minmax_of(&.ch_no)
    spawn update_stats!(crepo, sname, chmax: chmax)

    crepo.set_chmax(chmax: chmax, force: false, persist: true)
    crepo.update_vinfos!(start: chmin, limit: chmax &- chmin &+ 1)

    render json: {ch_no: chmin, pg_no: _pgidx(chmin, 32)}
  end

  private def update_stats!(crepo : Chrepo, sname : String, chmax : Int32)
    # puts "#{crepo.chmax}/#{chmax}/#{crepo.stype}"
    case crepo.stype
    when 0_i16
      wstem = get_wstem(sname, crepo.sn_id)
      wstem.update_stats!(chmax: chmax, persist: true)
    when 1_i16
      ustem = get_ustem(crepo.sn_id, sname)
      ustem.update_stats!(chmax: chmax, persist: true)
    when 2_i16
      rstem = get_rstem(sname, crepo.sn_id.to_s)
      rstem.update_stats!(chmax: chmax, persist: true)
    else
      raise "invalid type: #{sname}"
    end
  end

  # @[AC::Route::PATCH("/:ch_no", body: :form)]
  # def update_line(form : ZtextForm, up_id : Int32, sname : String, ch_no : Int32)
  #   guard_edit_privi up_id: up_id, sname:rege sname

  #   ustem = get_ustem(up_id, sname)
  #   cinfo = get_cinfo(ustem, ch_no)

  #   form.save!(ustem, cinfo, user: _uname)

  #   render json: cinfo
  # end
end
