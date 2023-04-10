require "./_sp_ctrl_base"

require "../../mtapp/sp_core"
require "../util/*"

class SP::TranCtrl < AC::Base
  base "/_sp"

  @[AC::Route::PUT("/hanviet")]
  def hanviet(mode : String = "mtl", cap_first : Bool = true)
    input = request.body.try(&.gets_to_end) || ""

    output = String.build do |io|
      sp_mt = MT::SpCore.sino_vi
      plain = mode != "mtl"

      input.each_line do |line|
        data = sp_mt.tokenize(line)
        plain ? data.to_txt(io, cap: cap_first) : data.to_mtl(io, cap: cap_first)
        io << '\n'
      end
    end

    response.content_type = "text/plain; charset=utf-8"
    render text: output
  end

  @[AC::Route::POST("/btran")]
  def btran(sl : String = "zh", tl : String = "vi", no_cap : Bool = false)
    input = request.body.try(&.gets_to_end) || ""

    output = Btran.translate(input.lines, source: sl, target: tl, no_cap: no_cap)
    output = output.join('\n', &.[1])

    context.response.content_type = "text/plain; charset=utf-8"
    render text: output
  end

  @[AC::Route::POST("/deepl")]
  def deepl(sl : String = "zh", tl : String = "en", no_cap : Bool = false)
    @render_called = true
    res = @context.response

    res.status_code = 200
    res.content_type = "text/plain; charset=utf-8"

    text = request.body.try(&.gets_to_end) || ""
    output = Deepl.translate(text.lines, source: sl, target: tl, no_cap: no_cap)

    output.each_with_index do |line, i|
      res << '\n' if i > 0
      res << line[1]
    end
  end
end
