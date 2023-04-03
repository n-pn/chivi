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

  @[AC::Route::POST("/users/info", body: :data)]
  def user_info(data : RawYsUser, rtime : Int64 = Time.utc.to_unix)
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

  @[AC::Route::POST("/crits/by_user", body: :data)]
  def crits_by_user(data : RawBookComments, rtime : Int64 = Time.utc.to_unix)
    guard_empty data.comments

    raw_ysuser = data.comments.first.user
    ysuser = YS::Ysuser.upsert!(raw_ysuser)

    if ysuser.crit_total < data.total
      ysuser.update!({crit_total: data.total, crit_rtime: rtime})
    end

    ysuser.save!

    Yscrit.bulk_upsert(data.comments)
    render text: data.comments.size
  end

  @[AC::Route::POST("/crits/by_book", body: :data)]
  def crits_by_book(data : RawBookComments, rtime : Int64 = Time.utc.to_unix)
    guard_empty data.comments

    ysbook = Ysbook.load(data.comments.first.book.id)

    if ysbook.crit_total < data.total
      ysbook.update!({crit_total: data.total})
    end

    Yscrit.bulk_upsert(data.comments)
    render text: data.comments.size
  end

  @[AC::Route::POST("/crits/by_list/:yl_id", body: :data)]
  def crits_by_list(data : RawListEntries, yl_id : String, rtime : Int64 = Time.utc.to_unix)
    yslist = Yslist.load(yl_id)

    yslist.book_total = data.total if yslist.book_total < data.total
    yslist.book_rtime = rtime

    yslist.save!

    Yscrit.bulk_upsert(data.books, yslist: yslist, save_text: true)
    render text: data.books.size
  end

  @[AC::Route::POST("/lists/by_user/:yu_id", body: :json)]
  def lists_by_user(json : RawListEntries, yu_id : Int32, rtime : Int64 = Time.utc.to_unix)
    yuser = Ysuser.load(yu_id)

    yuser.list_total = json.total if yuser.list_total < json.total
    yuser.list_rtime = rtime

    # Yslist.bulk_upsert(json.lists)
    render text: json.total
  end

  @[AC::Route::POST("/repls/by_crit/:yc_id", body: :json)]
  def repls_by_crit(json : RawCritReplies, yc_id : String, rtime : Int64 = Time.utc.to_unix)
    yscrit = Yscrit.load(yc_id)

    yscrit.repl_total = json.total if yscrit.repl_total < json.total
    yscrit.repl_rtime = rtime
    yscrit.save!

    Ysrepl.bulk_upsert(json.repls)
    render text: json.total
  end
end
