require "../../mt_ai/core/qt_core"
require "./_sp_ctrl_base"
require "../util/*"

# require "../../_data/logger/qtran_xlog"

class SP::TranCtrl < AC::Base
  base "/_sp/qtran"

  @[AC::Route::POST("/:type")]
  def tl_text(type : String, opts : String = "", redo : Bool = false)
    qdata = QtData.from_ztext(self._read_body)
    do_translate(qdata, type, opts, redo)
  end

  @[AC::Route::GET("/:type/:name")]
  def tl_file(type : String, name : String, opts : String = "", redo : Bool = false)
    qdata = QtData.from_fname(name)
    do_translate(qdata, type, opts, redo)
  end

  private def do_translate(qdata : QtData, type : String, opts = "", redo = false)
    response.headers["ETag"] = qdata.fname
    response.content_type = "text/plain; charset=utf-8"

    vtext = qdata.get_vtran(type, opts: opts, redo: redo)
    render text: vtext
  end
end
