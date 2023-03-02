require "../_ctrl_base"

class CV::VcoinXlogCtrl < CV::BaseCtrl
  base "/_db/vcoins"

  @[AC::Route::GET("/")]
  def index(vu_id : Int32? = nil)
    vu_id = _vu_id if _privi < 3
    pg_no, limit, offset = _paginate(min: 50)

    select_stmt = String.build do |stmt|
      stmt << "select id, sender, sendee, cast(amount as real) as amount, reason, ctime"
      stmt << " from " << VcoinXlog.table
      stmt << " where sender = #{vu_id} or sendee = #{vu_id}" if vu_id
      stmt << " order by id desc"
      stmt << " limit ? offset ?"
    end

    entries = VcoinXlog.select(select_stmt, limit, offset)

    user_ids = Set(Int32).new
    entries.each { |entry| user_ids << entry.sender << entry.sendee }
    viusers = Viuser.preload(user_ids)

    total = VcoinXlog.count(vu_id)

    render json: {
      xlogs: entries,
      users: ViuserView.as_hash(viusers),
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }
  end
end
