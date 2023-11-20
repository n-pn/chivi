require "../_ctrl_base"
require "./uprivi_form"

class CV::UpriviCtrl < CV::BaseCtrl
  base "/_db/uprivis"

  @[AC::Route::GET("/mine")]
  def mine
    uprivi = Uprivi.load!(_vu_id)
    render json: uprivi
  end

  @[AC::Route::PUT("/upgrade", body: :form)]
  def upgrade_privi(form : UpriviForm)
    _log_action("ug-privi", form)

    viuser = form.do_upgrade!(_vu_id)
    save_current_user!(viuser)

    render json: ViuserView.new(viuser, true)
  rescue ex
    Log.error(exception: ex) { ex }
    render 400, text: "Bạn chưa đủ số vcoin tối thiểu để tăng quyền hạn!"
  end
end
