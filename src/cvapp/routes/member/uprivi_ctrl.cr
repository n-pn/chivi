require "../_ctrl_base"
require "./uprivi_form"

class CV::UpriviCtrl < CV::BaseCtrl
  base "/_db/uprivis"

  @[AC::Route::GET("/mine")]
  def mine
    items = Uprivi.get_all(self._vu_id, &.<< " where vu_id = $1 order by privi desc")
    render json: items
  end

  @[AC::Route::PUT("/upgrade", body: :form)]
  def upgrade_privi(form : UpriviForm)
    guard_privi 0, "nâng cấp quyền hạn"
    spawn _log_action("upgrade-privi", form)

    viuser = form.do_upgrade!(_vu_id)
    save_current_user!(viuser)

    view = ViuserView.new(viuser, true)
    render json: view
  rescue ex
    Log.error(exception: ex) { ex }
    render 400, text: "Bạn chưa đủ số vcoin tối thiểu để tăng quyền hạn!"
  end
end
