require "./_wn_ctrl_base"
require "../../_util/diff_util"

require "../data/viuser/chtext_full_edit"

require "./forms/chtext_line_form"
require "./forms/chtext_full_form"

class WN::ChtextCtrl < AC::Base
  base "/_wn/texts/:wn_id/:sname"

  @[AC::Route::POST("/", body: :list)]
  def upsert_bulk(list : Array(ChtextFullForm), wn_id : Int32, sname : String)
    raise "Bạn chỉ được upload nhiều nhất 32 chương một lúc!" if list.size > 32
    guard_edit_privi wn_id: wn_id, sname: sname

    wnseed = get_wnseed(wn_id, sname)
    list.each(&.save!(seed: wnseed, user: _uname))

    chmin = list.first.ch_no
    chmax = list.last.ch_no

    wnseed.update_chap_vinfos!(chmin, chmax)
    wnseed.update_stats!(chmax: chmax, mtime: Time.utc.to_unix)

    render json: {pg_no: _pgidx(chmin, 32)}
  end

  @[AC::Route::PUT("/", body: :form)]
  def upsert_chap(form : ChtextFullForm, wn_id : Int32, sname : String)
    guard_edit_privi wn_id: wn_id, sname: sname

    wnseed = get_wnseed(wn_id, sname)
    chinfo = form.save!(seed: wnseed, user: _uname)

    chmin = chinfo.ch_no - 5
    chmax = chinfo.ch_no + 5

    wnseed.update_chap_vinfos!(chmin, chmax)
    wnseed.update_stats!(chmax: chinfo.ch_no, mtime: Time.utc.to_unix)

    render json: chinfo
  end

  @[AC::Route::GET("/:ch_no")]
  def show(wn_id : Int32, sname : String, ch_no : Int32)
    wnseed = get_wnseed(wn_id, sname)
    chinfo = wnseed.load_chap(ch_no)

    chtext = Chtext.new(wnseed, chinfo)

    render json: {
      ztext: chtext.load_all!,
      title: chinfo.ztitle,
      chdiv: chinfo.zchdiv,
    }
  end

  def guard_edit_privi(wn_id : Int32, sname : String)
    type = SeedType.parse(sname)

    edit_privi = type.edit_privi(sname == "@#{_uname}")
    edit_privi -= 1 if wn_id == 0

    guard_privi edit_privi, action: "thêm chương tiết cho nguồn #{type.type_name}"
  end

  @[AC::Route::PATCH("/:ch_no", body: :form)]
  def update_line(form : ChtextLineForm, wn_id : Int32, sname : String, ch_no : Int32)
    guard_edit_privi wn_id: wn_id, sname: sname

    wnseed = get_wnseed(wn_id, sname)
    chinfo = get_chinfo(wnseed, ch_no)

    form.save!(wnseed, chinfo, user: _uname)

    render json: chinfo
  end
end
