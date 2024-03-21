require "./_ctrl_base"
require "./czdata_form"

class RD::CzdataCtrl < AC::Base
  base "/_rd/czdatas"

  @[AC::Route::GET("/:sname/:sn_id/:ch_no")]
  def get_ztext(sname : String, sn_id : Int32, ch_no : Int32)
    crepo = Tsrepo.load!("#{sname}/#{sn_id}")

    owner, plock = crepo.edit_privi(self._vu_id)
    guard_owner owner, plock, "truy cập text gốc của chương"

    ch_no = crepo.chmax &+ 1 if ch_no < 1
    zdata = crepo.get_zdata(ch_no, rmode: 1)

    chdiv = zdata.chdiv.empty? ? crepo.suggest_chdiv(ch_no) : zdata.chdiv
    ztext = "///#{chdiv}\n#{zdata.cbody}"

    render json: {ch_no: ch_no, ztext: ztext}
  end

  @[Flags]
  enum UploadKind
    First; Last; Edit
  end

  TMP_DIR = "/2tb/zroot/ztext"

  @[AC::Route::POST("/:sname/:sn_id", body: :clist)]
  def upsert(sname : String, sn_id : Int32,
             clist : Array(CzdataForm), ukind : Int32 = 1)
    raise "Bạn chỉ được đăng tải nhiều nhất 64 chương một lúc!" if clist.size > 64

    ukind = UploadKind.from_value(ukind)
    crepo = Tsrepo.load!("#{sname}/#{sn_id}")

    owner, plock = crepo.edit_privi(self._vu_id)
    guard_owner owner, plock, "thêm text gốc cho nguồn truyện"

    mtime = Time.utc.to_unix

    spawn do
      save_dir = "var/ulogs/ztext/#{sname}-#{sn_id}"
      Dir.mkdir_p(save_dir) if ukind.first?
      fpath = "#{save_dir}/#{mtime}-#{_uname}-#{clist[0].ch_no}-#{ukind}.json"
      File.write(fpath, clist.to_json)
    end

    crepo.zdata_db.open_tx do |db|
      zorig = ukind.edit? ? "*#{_uname}" : "+#{_uname}"
      clist.each do |cform|
        zdata = cform.to_czdata(db: db, zorig: zorig, mtime: mtime)
        zdata.save_ztext!(db)
      end
    end

    chmin, chmax = clist.minmax_of(&.ch_no)
    spawn update_stats!(crepo, sname, chmax: chmax)

    crepo.set_chmax(chmax: chmax, force: false, persist: true)

    render json: {ch_no: chmin, pg_no: _pgidx(chmin, 32)}
  end

  private def update_stats!(crepo : Tsrepo, sname : String, chmax : Int32)
    # puts "#{crepo.chmax}/#{chmax}/#{crepo.stype}"
    case crepo.sname[0]
    when '~'
      wbook = get_wbook(wn_id: crepo.sn_id)
      wbook.update_stats!(chmax: chmax, persist: true)
    when '@'
      ustem = get_ustem(crepo.sn_id, sname: sname)
      ustem.update_stats!(chmax: chmax)
    when '!'
      rstem = get_rstem(sname: sname, sn_id: crepo.sn_id)
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
