require "./_ctrl_base"

class RD::UnlockCtrl < AC::Base
  base "/_rd/unlocks"

  @[AC::Route::GET("/")]
  def index(
    kw ulkey : String? = nil,
    by vu_id : Int32? = nil,
    to owner : Int32? = nil,
    _s order : String = "ctime"
  )
    pg_no, limit, offset = _paginate(min: 25, max: 100)

    query, args = Unlock.build_select_sql(
      ulkey: ulkey, vu_id: vu_id,
      owner: owner, order: order,
    )

    args << limit << offset
    items = Unlock.db.query_all(query, args: args, as: Unlock)

    if items.size < limit
      total = items.size &+ offset
    else
      query = query.sub("select *", "select vu_id")
      args[-2] = limit &* 3
      total = Upstem.db.query_all(query, args: args, as: Int32).size &+ offset
    end

    vu_ids = Set(Int32).new
    items.each { |x| vu_ids << x.owner << x.vu_id }

    json = {
      items: items,
      users: ViuserView.get_all(vu_ids).to_h { |x| {x.vu_id, x} },
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }
    render json: json
  end
end
