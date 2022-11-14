require "./_shared"
require "../engine"
require "../service/*"

class TL::TranslateCtrl < TL::BaseCtrl
  base "/_mh"

  struct HanvietReq
    include JSON::Serializable

    getter lines : Array(String)
    getter mode : String = "txt"
    getter cap : Bool = true
  end

  @[AC::Route::PUT("/hanviet", body: :req)]
  def hanviet(req : HanvietReq)
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

  @[AC::Route::PUT("/btran", body: :text)]
  def btran(text : String, no_cap : Bool = false)
    @render_called = true
    res = @context.response

    res.status_code = 200
    res.content_type = "text/plain; charset=utf-8"

    output = Btran.translate(text.split('\n'), no_cap: no_cap)
    output.join(res, '\n')
  end

  @[AC::Route::PUT("/deepl", body: :text)]
  def deepl(text : String, no_cap : Bool = false)
    @render_called = true
    res = @context.response

    res.status_code = 200
    res.content_type = "text/plain; charset=utf-8"

    output = Deepl.translate(text.split('\n'), no_cap: no_cap)
    output.join(res, '\n')
  end
end
