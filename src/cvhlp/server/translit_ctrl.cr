require "./_shared"
require "../engine"

class TL::TranslitCtrl < TL::BaseCtrl
  base "/_mh"

  class TranslitInput
    include JSON::Serializable

    getter lines : Array(String)
    getter mode : String = "txt"
    getter cap : Bool = true
  end

  @[AC::Route::PUT("/hanviet", body: :req)]
  def hanviet(req : TranslitInput)
    @render_called = true
    res = @context.response

    res.status_code = 200
    res.content_type = "text/plain; charset=utf-8"

    engine = Engine.hanviet

    req.lines.each_with_index do |line, idx|
      res << '\n' if idx > 0
      data = engine.convert(line)
      req.mode == "txt" ? data.to_txt(res, cap: req.cap) : data.to_mtl(res, cap: req.cap)
    end
  end
end
