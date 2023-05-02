require "../_ctrl_base"
require "../../../_util/mail_util"

class CV::ViuserCtrl < CV::BaseCtrl
  base "/_db/users"

  @[AC::Route::GET("/:uname")]
  def show(uname : String)
    user = Viuser.load!(uname)

    render json: {
      vu_id: user.id,
      uname: user.uname,
      privi: user.privi,
    }
  end
end
