require "./_ctrl_base"
require "./tsmemo_view"

class RD::RdmemoCtrl < AC::Base
  base "/_rd/rdmemos"

  @[AC::Route::GET("/")]
  def index(stype : Int32 = -1, state : Int32 = -1,
            rtype : String = "", order : String = "rtime")
    pg_no, limit, offset = self._paginate(min: 1, max: 50)

    items = TsmemoView.get_all(
      self._vu_id,
      stype: stype,
      state: state,
      rtype: rtype,
    )

    total = offset

    if items.size < limit
      total &+= items.size
    else
      total &+= TsmemoView.get_all(self._vu_id, stype, state, rtype, limit: limit * 3, offset: offset).size
    end

    json = {items: items, pgidx: pg_no, pgmax: _pgidx(total, limit)}
    render json: json
  end

  @[AC::Route::GET("/reading")]
  def reading(vu uname : String = self._uname, st state : Int32 = -1)
    pg_no, limit, offset = self._paginate(min: 1, max: 50)
    total = offset

    vu_id = Rdmemo.get_vu_id(uname) || self._vu_id
    memos = Rdmemo.get_all(vu_id: vu_id, sname: "~avail", state: state, rtype: "", limit: limit, offset: offset)

    if memos.size < limit
      total &+= memos.size
    else
      total &+= Rdmemo.get_all(vu_id: vu_id, sname: "~avail", state: state, rtype: "", limit: limit * 3, offset: offset).size
    end

    json = {memos: memos, pgidx: pg_no, pgmax: self._pgidx(total, limit)}
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
  def show(sname : String, sn_id : Int32)
    sname = sname.sub(/wn|up|rm/, "")
    rmemo = Rdmemo.load!(vu_id: self._vu_id, sname: sname, sn_id: sn_id)
    render json: rmemo
  end
end
