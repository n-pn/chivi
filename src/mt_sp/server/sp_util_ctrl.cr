require "icu"
require "./_sp_ctrl_base"
require "../../_util/tran_util"

class SP::UtilCtrl < AC::Base
  base "/_sp"

  # add_parser("text/plain") { |klass, body_io| klass.from_json(body_io) }

  @[AC::Route::POST("/chardet")]
  def chardet
    input = request.body.not_nil!.gets_to_end
    icu = ICU::CharsetDetector.new
    render text: icu.detect(input).name
  end

  @[AC::Route::POST("/opencc")]
  def opencc(config = "hk2s")
    input = request.body.not_nil!.gets_to_end
    render text: TranUtil.opencc(input, config)
  end
end
