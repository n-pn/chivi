require "./_ctrl_base"
require "../../_util/hash_util"

class RD::RmchapCtrl < AC::Base
  base "/_rd/rmchaps/:sname/:sn_id"

  @[AC::Route::GET("/")]
  def index(sname : String, sn_id : String, reverse : Bool = false)
    # TODO: restrict user access?
    rstem = get_rstem(sname, sn_id)
    _pg_no, limit, offset = _paginate(min: 1, max: 64)

    if reverse
      chaps = rstem.crepo.get_top(start: rstem.crepo.chmax &- offset, limit: limit)
    else
      chaps = rstem.crepo.get_all(start: offset, limit: limit)
    end

    render json: chaps
  end

  @[AC::Route::GET("/:ch_no/:p_idx")]
  def show(sname : String, sn_id : String, ch_no : Int32, p_idx : Int32)
    rstem = get_rstem(sname, sn_id)
    cinfo = get_cinfo(rstem, ch_no)
    rdata = rstem.crepo.part_data(cinfo, p_idx, _privi)
    render 200, json: rdata
  end
end
