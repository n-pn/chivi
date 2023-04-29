require "./_ys_ctrl_base"

require "../_raw/*"
require "../data/*"

class YS::InitCtrl < AC::Base
  base "/_ys"

  @[AC::Route::POST("/books/info", body: :json)]
  def book_info(json : RawYsbook, rtime : Int64 = Time.utc.to_unix)
    json.info_rtime = rtime

    if model = Ysbook.upsert!(json)
      render json: {y_bid: model.id, wn_id: model.nvinfo_id}
    else
      render json: {y_bid: 0, wn_id: 0}
    end
  end

  @[AC::Route::POST("/users/info", body: :data)]
  def user_info(data : RawYsuser, rtime : Int64 = Time.utc.to_unix)
    ysuser = Ysuser.load(data.user.id)

    ysuser.set_data(data.user)
    ysuser.set_stat(data, rtime)

    ysuser.save!

    render text: ysuser.id
  end

  macro guard_empty(list)
    if {{list.id}}.empty?
      render text: 0
      return
    end
  end

  @[AC::Route::POST("/crits/by_user", body: :json)]
  def crits_by_user(json : RawBookComments, rtime : Int64 = Time.utc.to_unix)
    guard_empty json.comments

    raw_ysuser = json.comments.first.user
    Ysuser.update_crit_total(raw_ysuser.id, json.total, rtime)

    YscritForm.bulk_upsert!(json.comments, rtime: rtime)
    render text: json.comments.size
  end

  @[AC::Route::POST("/crits/by_book", body: :json)]
  def crits_by_book(json : RawBookComments, rtime : Int64 = Time.utc.to_unix)
    guard_empty json.comments
    ysbook = json.comments.first.book

    PG_DB.exec <<-SQL, json.total, ysbook.id
      update ysbooks set crit_total = $1
      where id = $2 and crit_total < $1
      SQL

    YscritForm.bulk_upsert!(json.comments, rtime: rtime)
    render text: json.comments.size
  end

  @[AC::Route::POST("/crits/by_list/:yl_id", body: :json)]
  def crits_by_list(json : RawListEntries, yl_id : String, rtime : Int64 = Time.utc.to_unix)
    yl_id = yl_id.hexbytes
    Yslist.update_book_total(yl_id, json.total, rtime)
    crits = YscritForm.bulk_upsert!(json.books, rtime: rtime)

    vl_id = YS::DBRepo.get_vl_id(yl_id)
    YscritForm.update_list_id(crits.map(&.id!), yl_id, vl_id)

    render text: json.books.size
  end

  @[AC::Route::POST("/lists/by_user/:yu_id", body: :json)]
  def lists_by_user(json : RawListEntries, yu_id : Int32, rtime : Int64 = Time.utc.to_unix)
    Ysuser.update_list_total(yu_id, json.total, rtime)
    # Yslist.bulk_upsert(json.lists)
    render text: json.total
  end

  @[AC::Route::POST("/repls/by_crit/:yc_id", body: :json)]
  def repls_by_crit(json : RawCritReplies, yc_id : String, rtime : Int64 = Time.utc.to_unix)
    yc_id = yc_id.hexbytes
    vc_id = DBRepo.get_vc_id(yc_id)
    repls = json.repls

    unless repls.empty?
      YsuserForm.bulk_upsert!(json.repls.map(&.user))
      YsreplForm.bulk_upsert!(json.repls, rtime, vc_id)
    end

    YscritForm.update_repl_total(yc_id, json.total, rtime)
    render text: json.total
  end
end
