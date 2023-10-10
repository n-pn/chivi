require "../_ctrl_base"
require "./xvcoin_form"

class CV::XvcoinCtrl < CV::BaseCtrl
  base "/_db/xvcoins"

  @[AC::Route::GET("/")]
  def index(vu_id : Int32? = nil)
    vu_id = _vu_id if _privi < 3
    pg_no, limit, offset = _paginate(min: 50)

    xlogs_query = Xvcoin.build_select_sql(vu_id)

    args = [limit, offset] of Int32
    args << vu_id if vu_id

    xlogs = Xvcoin.db.query_all(xlogs_query, args: args, as: Xvcoin)

    if xlogs.size < limit
      total = offset &+ xlogs.size
    else
      args[0] = limit &* 3
      total = offset &+ Xvcoin.db.query_all(xlogs_query, args: args, as: Xvcoin).size
    end

    vu_ids = Set(Int32).new
    xlogs.each { |x| vu_ids << x.sender_id << x.target_id }

    output = {
      xlogs: xlogs,
      users: ViuserView.as_hash(Viuser.preload(vu_ids)),

      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }

    render json: output
  end

  @[AC::Route::POST("/giving", body: :xform)]
  def send_vcoin(xform : XvcoinForm)
    unless target = xform.find_target
      raise BadRequest.new("Người bạn muốn tặng vcoin không tồn tại")
    end

    if _viuser.vcoin >= xform.amount
      raise BadRequest.new("Số vcoin khả dụng của bạn ít hơn số vcoin bạn muốn tặng")
    end

    xform.exchange!(sender: _viuser, target: target, xvkind: 0)

    _log_action("send-vcoin", xform)
    render json: {target: target.uname, remain: _viuser.vcoin}
  end

  @[AC::Route::POST("/donate", body: :xform)]
  def log_donate(xform : XvcoinForm)
    unless target = xform.find_target
      raise BadRequest.new("Tên người dùng không đúng")
    end

    xform.exchange!(sender: Viuser.system, target: target, xvkind: 60)

    _log_action("log-donate", xform)
    render json: {target: target.uname, amount: target.vcoin.round(3)}
  end
end
