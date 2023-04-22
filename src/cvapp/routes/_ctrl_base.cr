require "../../_data/**"
require "../views/*"

require "./_ctrl_util"

require "../../cv_srv"

abstract class CV::BaseCtrl < AC::Base
  # @[AC::Route::Filter(:before_action)]
  # def set_request_id
  #   request_id = request.headers["X-Request-ID"]? || UUID.random.to_s
  #   Log.context.set client_ip: client_ip, request_id: request_id
  #   response.headers["X-Request-ID"] = request_id
  # end

  getter _viuser : Viuser { Viuser.load!(_uname) }

  private def get_nvinfo(b_id : Int64) : Wninfo
    Wninfo.load!(b_id) || raise NotFound.new("Quyển sách không tồn tại")
  end

  def save_current_user!(user : Viuser) : Nil
    session["vu_id"] = user.id.to_i64
    session["uname"] = user.uname
    session["privi"] = user.privi.to_i64
    session["until"] = user.current_privi_until
  end
end
