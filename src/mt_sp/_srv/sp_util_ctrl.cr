require "./_sp_ctrl_base"

class SP::UtilCtrl < AC::Base
  base "/_sp/utils"

  @[AC::Route::GET("/defns")]
  def defns(zh ztext : String = "...")
    trans = ZvWord.get_trans(ztext)
    trans.push(call_qt_v1(ztext)).uniq!
    render text: trans.join('\n')
  rescue ex
    Log.error(exception: ex) { ztext }
    render status: 500, text: ex.message
  end

  @[AC::Route::GET("/names")]
  def names(zh ztext : String = "...")
    names = ZvName.get_names(ztext)
    names.push(MT::QtCore.tl_hvname(ztext)).uniq!
    render text: names.join('\n')
  rescue ex
    Log.error(exception: ex) { ztext }
    render status: 500, text: ex.message
  end

  private def call_qt_v1(ztext : String)
    q_url = "#{CV_ENV.m1_host}/_m1/qtran?zh=#{ztext}&wc=false"
    HTTP::Client.get(q_url, &.body_io.gets_to_end)
  end
end
