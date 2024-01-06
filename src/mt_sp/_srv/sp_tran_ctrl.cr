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
    sleep 10.milliseconds * (1 << (4 - self._privi))
    lines, mtime = qdata.get_vtran(type, opts: opts, redo: redo)

    response.headers["ETag"] = mtime.to_s
    response.content_type = "text/plain; charset=utf-8"

    render text: lines.join('\n')
  end
end
