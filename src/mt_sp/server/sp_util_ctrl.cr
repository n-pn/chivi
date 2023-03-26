require "icu"
require "./_sp_ctrl_base"
require "../../_util/post_util"
require "../../_util/tran_util"

class SP::UtilCtrl < AC::Base
  base "/_sp"

  # add_parser("text/plain") { |klass, body_io| klass.from_json(body_io) }

  @input : String = ""

  @[AC::Route::Filter(:before_action)]
  def before_action
    @input = request.body.try(&.gets_to_end) || ""
  end

  @[AC::Route::POST("/chardet")]
  def chardet
    icu = ICU::CharsetDetector.new
    render text: icu.detect(@input).name
  end

  @[AC::Route::POST("/opencc")]
  def opencc(config = "hk2s")
    render text: TranUtil.opencc(@input, config)
  end

  @[AC::Route::POST("/mdpost")]
  def mdpost
    render text: PostUtil.md_to_html(@input.strip)
  end
end
