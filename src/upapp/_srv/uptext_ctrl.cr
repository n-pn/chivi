require "./_up_ctrl_base"
require "./uptext_form"

class UP::UptextCtrl < AC::Base
  base "/_up/texts/:up_id"

  @[AC::Route::GET("/:ch_no")]
  def show_full(up_id : Int32, ch_no : Int32)
    ustem = get_ustem(up_id)
    # TODO: checl permission
    cinfo = get_cinfo(ustem, ch_no)

    render json: {
      ztext: cinfo.load_full!(ftype: "raw.txt"),
      title: cinfo.ztitle,
      chdiv: cinfo.zchdiv,
    }
  end

  @[AC::Route::GET("/:ch_no/for_mtl")]
  def for_mtl(up_id : Int32, ch_no : Int32)
    ustem = get_ustem(up_id)
    # TODO: checl permission
    cinfo = get_cinfo(ustem, ch_no)

    parts = [] of String
    mtl_1 = [] of Bool
    mtl_3 = [] of Bool
    mtl_2 = [] of Bool

    0.upto(cinfo.psize) do |p_idx|
      parts << cinfo.load_part!(p_idx, ftype: "raw.txt").join('\n')
      mtl_1 << File.file?(cinfo.file_path(p_idx, ftype: "mtl_1.con"))
      mtl_2 << File.file?(cinfo.file_path(p_idx, ftype: "mtl_2.con"))
      mtl_3 << File.file?(cinfo.file_path(p_idx, ftype: "mtl_3.con"))
    end

    json = {cksum: cinfo.cksum, parts: parts, mtl_1: mtl_1, mtl_3: mtl_3, mtl_2: mtl_2}
    render json: json
  end

  @[AC::Route::POST("/", body: :list)]
  def upsert_bulk(up_id : Int32, list : Array(UptextForm))
    raise "Bạn chỉ được upload nhiều nhất 32 chương một lúc!" if list.size > 32

    ustem = get_ustem(up_id)
    guard_owner ustem.viuser_id, 2, "thêm text gốc"

    list.each(&.save!(ustem: ustem, uname: _uname))

    chmin = list.first.ch_no
    chmax = list.last.ch_no

    ustem.tl_chap_info!(chmin, chmax)
    ustem.update_stats!(chmax: chmax, mtime: Time.utc.to_unix)

    render json: {pg_no: _pgidx(chmin, 32)}
  end

  @[AC::Route::PUT("/", body: :form)]
  def upsert_once(up_id : Int32, form : UptextForm)
    ustem = get_ustem(up_id)
    guard_owner ustem.viuser_id, 2, "thêm text gốc"

    cinfo = form.save!(ustem: ustem, uname: _uname)

    chmin = cinfo.ch_no - 5
    chmax = cinfo.ch_no + 5

    ustem.tl_chap_info!(chmin, chmax)
    ustem.update_stats!(chmax: cinfo.ch_no, mtime: Time.utc.to_unix)

    render json: cinfo
  end

  # @[AC::Route::PATCH("/:ch_no", body: :form)]
  # def update_line(form : UptextForm, up_id : Int32, sname : String, ch_no : Int32)
  #   guard_edit_privi up_id: up_id, sname: sname

  #   ustem = get_ustem(up_id, sname)
  #   cinfo = get_cinfo(ustem, ch_no)

  #   form.save!(ustem, cinfo, user: _uname)

  #   render json: cinfo
  # end
end
