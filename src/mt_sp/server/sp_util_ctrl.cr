require "icu"
require "./_sp_ctrl_base"

class SP::UtilCtrl < SP::BaseCtrl
  base "/_sp"

  @[AC::Route::POST("/chardet", body: input)]
  def chardet(input : String)
    icu = ICU::CharsetDetector.new
    render text: icu.detect(input).name
  end
end
