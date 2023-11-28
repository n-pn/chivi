require "./_ctrl_base"

class RD::RdmemoCtrl < AC::Base
  base "/_rd/rdmemos"

  @[AC::Route::GET("/")]
  def index(sname : String? = nil, rtype : String = "")
    sname = nil if sname && sname.blank?
    pg_no, limit, offset = _paginate(min: 5, max: 50)

    items = Rdmemo.get_all(self._vu_id, sname, rtype, limit, offset)
    total = offset

    if items.size < limit
      total &+= items.size
    else
      total &+= Rdmemo.get_all(self._vu_id, sname, rtype, limit * 3, offset).size
    end

    json = {items: items, pgidx: pg_no, pgmax: _pgidx(total, limit)}
    render json: json
  end

  @[AC::Route::PUT("/:action", body: :mform)]
  def upsert(mform : Rdmemo, action : String)
    mform.vu_id = self._vu_id

    rmemo = Rdmemo.find(mform.vu_id, mform.sname, mform.sn_id)
    rmemo = rmemo.try(&.inherit(mform, action)) || mform

    rmemo = rmemo.upsert!
    render json: rmemo
  rescue ex
    Log.error(exception: ex) { mform.to_json }
    render 500, text: ex.message
  end

  @[AC::Route::GET("/:sname/:sn_id")]
  def show(sname : String, sn_id : String)
    rmemo = Rdmemo.load!(vu_id: self._vu_id, sname: sname, sn_id: sn_id)
    render json: rmemo
  end
end
