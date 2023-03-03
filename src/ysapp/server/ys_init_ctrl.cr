require "./_ys_ctrl_base"

require "../models/*"
require "../_raw/*"

class YS::InitCtrl < AC::Base
  base "/_ys"

  @[AC::Route::POST("/users/info", body: :json)]
  def user_info(json : RawYsUser, rtime : Int64 = Time.utc.to_unix)
    y_uid = Ysuser.upsert_info_from_raw_data(json, rtime)
    render text: y_uid
  end

  @[AC::Route::POST("/crits/by_user", body: :json)]
  def crits_by_user(json : RawBookComments, rtime : Int64 = Time.utc.to_unix)
    Ysuser.update_stats_from_raw_data(json, rtime)

    render text: json.total
  end
end
