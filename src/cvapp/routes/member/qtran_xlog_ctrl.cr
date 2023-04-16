require "../_ctrl_base"

class CV::QtranXlogCtrl < CV::BaseCtrl
  base "/_db/qtran_xlogs"

  @[AC::Route::GET("/")]
  def index(vu_id : Int32? = nil)
    vu_id = _vu_id if _privi < 3
    pg_no, limit, offset = _paginate(min: 50, max: 100)

    total = QtranXlog.count(vu_id)
    entries = QtranXlog.fetch(vu_id, limit, offset)
    viusers = Viuser.preload(entries.map(&.viuser_id))

    render json: {
      xlogs: entries,
      users: ViuserView.as_hash(viusers),
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }
  end

  @[AC::Route::GET("/stats")]
  def stats(scope : String = "today")
    t_now = Time.local

    case scope
    when "yesterday"
      from, upto = t_now - 1.day, t_now
    when "last_7_days"
      from, upto = t_now - 1.day, t_now
    else # assume today is the default
      from, upto = t_now, t_now + 1.days
    end

    user_stats = QtranXlog.user_stats(from, upto)
    user_infos = Viuser.preload(user_stats.map(&.viuser_id))

    book_stats = QtranXlog.book_stats(from, upto)
    book_infos = Wninfo.preload(book_stats.map(&.wninfo_id))

    render json: {
      user_stats: user_stats,
      user_infos: ViuserView.as_hash(user_infos),
      book_stats: book_stats,
      book_infos: WninfoView.as_hash(book_infos),
    }
  end
end
