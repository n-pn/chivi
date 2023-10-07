require "./_ctrl_base"
require "../../_util/hash_util"

class RD::UpchapCtrl < AC::Base
  base "/_rd/upchaps/:sname/:up_id"

  @[AC::Route::GET("/")]
  def index(up_id : Int32, reverse : Bool = false)
    # TODO: restrict user access?
    ustem = get_ustem(up_id)
    _pg_no, limit, offset = _paginate(min: 32, max: 64)

    if reverse
      chaps = ustem.crepo.get_top(start: ustem.crepo.chmax &- offset, limit: limit)
    else
      chaps = ustem.crepo.get_all(start: offset, limit: limit)
    end

    render json: chaps
  end

  @[AC::Route::GET("/:ch_no/:p_idx")]
  def show(sname : String, up_id : Int32, ch_no : Int32, p_idx : Int32)
    ustem = get_ustem(up_id)
    cinfo = get_cinfo(ustem, ch_no)

    vu_id = self._vu_id
    privi = vu_id == ustem.viuser_id ? 5 : _privi

    rdata = ustem.crepo.part_data(cinfo, p_idx, vu_id, privi)
    render 200, json: rdata
  end
end
