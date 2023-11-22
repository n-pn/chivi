require "./_mt_ctrl_base"

require "../data/vi_dict"
require "../data/vi_term"

class MT::ZvDictCtrl < AC::Base
  base "/_ai/dicts"

  @[AC::Route::GET("/")]
  def index(kind = "")
    pg_no, limit, offset = _paginate(min: 10, max: 50)
    limit = 999 if kind.empty?

    dicts = ZvDict.fetch_all(kind, limit, offset)

    if dicts.size < limit
      total = offset &+ dicts.size
    else
      total = ZvDict.count(kind)
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
    dname = dname.sub("book:", "wn").sub(":", "")
    dinfo = ZvDict.load!(dname)

    json = {dinfo: dinfo, users: dinfo.users.split(',', remove_empty: true)}

    render json: json
  end
end
