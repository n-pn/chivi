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

    vuser = form.do_upgrade!(_vu_id)
    self.save_current_user!(vuser)

    uquota = Uquota.load(self._vu_id, self.client_ip)
    uquota.set_privi_bonus!(vuser.privi)

    view = ViuserFull.new(vuser, uquota)
    render json: view
  rescue ex
    Log.error(exception: ex) { ex }
    render 400, text: "Bạn chưa đủ số vcoin tối thiểu để tăng quyền hạn!"
  end
end
