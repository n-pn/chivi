require "./_ys_ctrl_base"

require "../models/*"
require "../_raw/*"

class YS::InitCtrl < AC::Base
  base "/_ys"

  @[AC::Route::POST("/books/info", body: :json)]
  def book_info(json : RawYsBook, rtime : Int64 = Time.utc.to_unix)
    json.info_rtime = rtime

    if model = Ysbook.upsert!(json)
      render json: {y_bid: model.id, wn_id: model.nvinfo_id}
    else
      render json: {y_bid: 0, wn_id: 0}
    end
  end

  @[AC::Route::POST("/users/info", body: :json)]
  def user_info(json : RawYsUser, rtime : Int64 = Time.utc.to_unix)
    y_uid = Ysuser.upsert_info_from_raw_data(json, rtime)
    render text: y_uid
  end

  @[AC::Route::POST("/crits/by_user", body: :data)]
  def crits_by_user(data : RawBookComments, rtime : Int64 = Time.utc.to_unix)
    if data.comments.empty?
      render text: 0
      return
    end

    raw_ysuser = data.comments.first.user
    ysuser = YS::Ysuser.upsert!(raw_ysuser)

    ysuser.crit_total = data.total if ysuser.crit_total < data.total
    ysuser.crit_rtime = rtime

    ysuser.save!

    Yscrit.bulk_upsert(data.comments)
    render text: data.comments.size
  end

  @[AC::Route::POST("/crits/by_list/:y_lid", body: :data)]
  def crits_by_list(data : RawListEntries, y_lid : String, rtime : Int64 = Time.utc.to_unix)
    yslist = Yslist.load(y_lid)

    yslist.book_total = data.total if yslist.book_total < data.total
    yslist.book_rtime = rtime

    Yscrit.bulk_upsert(data.books)
    render text: data.books.size
  end

  @[AC::Route::POST("/lists/by_user/:y_uid", body: :json)]
  def lists_by_user(json : RawListEntries, y_uid : Int32, rtime : Int64 = Time.utc.to_unix)
    yuser = Ysuser.load(y_uid)

    yuser.list_total = json.total if yuser.list_total < json.total
    yuser.list_rtime = rtime

    # Yslist.bulk_upsert(json.lists)
    render text: json.total
  end
end
