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

  @[AC::Route::POST("/crits/by_user", body: :json)]
  def crits_by_user(json : RawBookComments, rtime : Int64 = Time.utc.to_unix)
    guard_empty json.comments
    raw_ysuser = json.comments.first.user

    PG_DB.exec <<-SQL, json.total, rtime, raw_ysuser.id
      update ysusers
      set crit_total = $1, crit_rtime = $2
      where yu_id = $3 and list_total < $1
      SQL

    Yscrit.bulk_upsert(json.comments)
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

    Yscrit.bulk_upsert(json.comments)
    render text: json.comments.size
  end

  @[AC::Route::POST("/crits/by_list/:yl_id", body: :json)]
  def crits_by_list(json : RawListEntries, yl_id : String, rtime : Int64 = Time.utc.to_unix)
    yl_id = yl_id.hexbytes

    PG_DB.exec <<-SQL, json.total, rtime, yl_id
      update yslists
      set book_total = $1, book_rtime = $2
      where yl_id = $3 and book_total < $1
      SQL

    crits = Yscrit.bulk_upsert(json.books, save_text: true)

    PG_DB.exec <<-SQL, yl_id, Yslist.get_id(yl_id), crits.map(&.id)
      update yscrits
      set yl_id = $1, yslist_id = $2
      where id = any ($3)
      SQL

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
    Yscrit.update_repl_total(yc_id.hexbytes, json.total, rtime)

    Ysuser.bulk_upsert!(json.repls.map(&.user))
    Ysrepl.bulk_upsert!(json.repls)

    render text: json.total
  end
end
