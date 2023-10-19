require "./_ctrl_base"

class RD::CzdataCtrl < AC::Base
  base "/_rd/zdata"

  @[AC::Route::GET("/wn/:sname/:sn_id/:ch_no")]
  def wn_text(sname : String, sn_id : Int32, ch_no : Int32)
    wstem = get_wstem(sname, sn_id)
    # TODO: check if also unlocked
    guard_privi 1, "truy cập text gốc của chương"

    output = get_text(wstem.crepo, ch_no)
    render json: output
  end

  @[AC::Route::GET("/rm/:sname/:sn_id/:ch_no")]
  def rm_text(sname : String, sn_id : String, ch_no : Int32)
    rstem = get_rstem(sname, sn_id)
    # TODO: check if also unlocked
    guard_privi 1, "truy cập text gốc của chương"

    output = get_text(rstem.crepo, ch_no)
    render json: output
  end

  @[AC::Route::GET("/up/:sname/:sn_id/:ch_no")]
  def up_text(sname : String, up_id : Int32, ch_no : Int32)
    ustem = get_ustem(up_id, sname)
    # TODO: check if also unlocked
    guard_owner ustem.owner, 1, "truy cập text gốc của chương"

    output = get_text(ustem.crepo, ch_no)
    render json: output
  end

  private def get_text(crepo : Chrepo, ch_no : Int32)
    if cinfo = crepo.find(ch_no)
      {ztext: crepo.load_raw!(cinfo), title: cinfo.ztitle, chdiv: cinfo.zchdiv}
    else
      {ztext: "", title: "", chdiv: crepo.get_chdiv(ch_no)}
    end
  end

  # @[AC::Route::GET("/:ch_no/for_mtl")]
  # def for_mtl(up_id : Int32, ch_no : Int32)
  #   ustem = get_ustem(up_id)
  #   # TODO: checl permission
  #   cinfo = get_cinfo(ustem, ch_no)

  #   parts = [] of String
  #   mtl_1 = [] of Bool
  #   mtl_3 = [] of Bool
  #   mtl_2 = [] of Bool

  #   0.upto(cinfo.psize) do |p_idx|
  #     parts << cinfo.load_part!(p_idx, ftype: "raw.txt").join('\n')
  #     mtl_1 << File.file?(cinfo.file_path(p_idx, ftype: "mtl_1.con"))
  #     mtl_2 << File.file?(cinfo.file_path(p_idx, ftype: "mtl_2.con"))
  #     mtl_3 << File.file?(cinfo.file_path(p_idx, ftype: "mtl_3.con"))
  #   end

  #   json = {cksum: cinfo.cksum, parts: parts, mtl_1: mtl_1, mtl_3: mtl_3, mtl_2: mtl_2}
  #   render json: json
  # end

  @[AC::Route::POST("/wn/:sname/:sn_id", body: :clist)]
  def wn_bulk(sname : String, sn_id : Int32, clist : Array(ZtextForm))
    wstem = get_wstem(sname, sn_id)
    guard_privi 2, "thêm text gốc cho bộ truyện"

    save_bulk!(wstem.crepo, clist)
    wstem.update_stats!(chmax: clist.last.ch_no, atomic: true)

    render json: {pg_no: _pgidx(clist.first.ch_no, 32)}
  end

  @[AC::Route::POST("/up/:sname/:sn_id", body: :clist)]
  def up_bulk(sname : String, sn_id : Int32, clist : Array(ZtextForm))
    ustem = get_ustem(sn_id, sname)
    guard_owner ustem.owner, 1, "thêm text gốc cho sưu tầm cá nhân"

    save_bulk!(ustem.crepo, clist)
    ustem.update_stats!(chmax: clist.last.ch_no, mtime: Time.utc.to_unix)

    render json: {pg_no: _pgidx(clist.first.ch_no, 32)}
  end

  private def save_bulk!(crepo : Chrepo, clist : Array(ZtextForm))
    if clist.size > 32
      raise "Bạn chỉ được upload nhiều nhất 32 chương một lúc!"
    end

    clist.each(&.save!(crepo: crepo, uname: _uname))
    chmin = clist.first.ch_no
    chmax = clist.last.ch_no
    crepo.update_vinfos!(chmin &- 5, chmax &- chmin + 10)
  end

  @[AC::Route::PUT("/up/:sname/:sn_id", body: :cform)]
  def up_once(sn_id : Int32, cform : ZtextForm)
    ustem = get_ustem(sn_id)
    guard_owner ustem.owner, 1, "thêm text gốc cho sưu tầm cá nhân "

    cinfo = cform.save!(crepo: ustem.crepo, uname: _uname)

    ustem.crepo.update_vinfos!(start: cinfo.ch_no &- 5, limit: 10)
    ustem.update_stats!(chmax: cinfo.ch_no, mtime: Time.utc.to_unix)

    render json: cinfo
  end

  # @[AC::Route::PATCH("/:ch_no", body: :form)]
  # def update_line(form : ZtextForm, up_id : Int32, sname : String, ch_no : Int32)
  #   guard_edit_privi up_id: up_id, sname: sname

  #   ustem = get_ustem(up_id, sname)
  #   cinfo = get_cinfo(ustem, ch_no)

  #   form.save!(ustem, cinfo, user: _uname)

  #   render json: cinfo
  # end
end
