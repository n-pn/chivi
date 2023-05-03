require "icu"
require "colorize"

require "./_sp_ctrl_base"
require "../../_util/post_util"
require "../../_util/tran_util"

class SP::UtilCtrl < AC::Base
  base "/_sp"

  @[AC::Route::POST("/chardet")]
  def chardet
    icu = ICU::CharsetDetector.new
    encoding = icu.detect(_read_body).name
    render text: encoding
  end

  @[AC::Route::POST("/opencc")]
  def opencc(config = "hk2s")
    output = TranUtil.opencc(_read_body, config)
    render text: output
  end

  @[AC::Route::POST("/mdpost")]
  def mdpost
    html = PostUtil.md_to_html(_read_body.strip)
    render text: html
  end
end
