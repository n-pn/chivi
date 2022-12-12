require "icu"
require "./_shared"

class TL::HelperCtrl < TL::BaseCtrl
  base "/_mh"

  @[AC::Route::POST("/chardet", body: input)]
  def chardet(input : String)
    icu = ICU::CharsetDetector.new
    render text: icu.detect(input).name
  end
end
