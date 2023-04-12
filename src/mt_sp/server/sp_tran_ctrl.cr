require "./_sp_ctrl_base"

require "../../mtapp/sp_core"
require "../../mtapp/service/*"

class SP::TranCtrl < AC::Base
  base "/_sp"

  @input : String = ""

  @[AC::Route::Filter(:before_action)]
  def before_all_actions
    @input = request.body.try(&.gets_to_end) || ""
    response.content_type = "text/plain; charset=utf-8"
  end

  @[AC::Route::PUT("/hanviet")]
  def hanviet(mode : String = "mtl", cap_first : Bool = true)
    sp_mt = MT::SpCore.sino_vi
    plain = mode != "mtl"

    output = String.build do |io|
      @input.each_line do |line|
        data = sp_mt.tokenize(line)
        plain ? data.to_txt(io, cap: cap_first) : data.to_mtl(io, cap: cap_first)
        io << '\n'
      end
    end

    render text: output
  end

  @[AC::Route::POST("/btran")]
  def btran(sl : String = "zh", tl : String = "vi", no_cap : Bool = false)
    output = Btran.translate(@input.lines, source: sl, target: tl, no_cap: no_cap)
    render text: output.join('\n', &.[1])
  end

  @[AC::Route::POST("/deepl")]
  def deepl(sl : String = "zh", tl : String = "en", no_cap : Bool = false)
    output = Deepl.translate(@input.lines, source: sl, target: tl, no_cap: no_cap)
    render text: output.join('\n', &.[1])
  end
end
