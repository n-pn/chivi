require "./_sp_ctrl_base"
require "../data/pg_dict"

class SP::ZvdictCtrl < AC::Base
  base "/_sp/dicts"

  @[AC::Route::GET("/")]
  def index(kind = "")
    pg_no, limit, offset = _paginate(min: 10, max: 50)
    limit = 999 if kind.empty?

    dicts = PgDict.fetch_all(kind, limit, offset)

    if dicts.size < limit
      total = offset &+ dicts.size
    else
      total = PgDict.count(kind)
    end

    output = {
      dicts: dicts,
      total: total,
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }

    render json: output
  end

  @[AC::Route::GET("/:dname")]
  def show(dname : String)
    dinfo = PgDict.load!(dname)
    json = {dinfo: dinfo, users: dinfo.users}
    render json: json
  end
end
