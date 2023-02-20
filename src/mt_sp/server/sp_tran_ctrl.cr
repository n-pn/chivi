require "./_sp_ctrl_base"

require "../sp_core"
require "../util/*"

class SP::TranCtrl < AC::Base
  base "/_sp"

  struct HanvietForm
    include JSON::Serializable

    getter lines : Array(String)
    getter mode : String = "txt"
    getter cap : Bool = true
  end

  @[AC::Route::PUT("/hanviet")]
  def hanviet(mode : String = "mtl", cap_first : Bool = true)
    @render_called = true
    res = @context.response

    res.status_code = 200
    res.content_type = "text/plain; charset=utf-8"

    engine = Engine.hanviet

    input = request.body.not_nil!.gets_to_end
    input.lines.each_with_index do |line, idx|
      res << '\n' if idx > 0
      data = engine.convert(line)
      mode == "txt" ? data.to_txt(res, cap: cap_first) : data.to_mtl(res, cap: cap_first)
    end
  end

  @[AC::Route::PUT("/btran")]
  def btran(sl : String = "zh", tl : String = "vi", no_cap : Bool = false)
    @render_called = true
    res = @context.response

    res.status_code = 200
    res.content_type = "text/plain; charset=utf-8"

    text = request.body.not_nil!.gets_to_end
    output = Btran.translate(text.lines, source: sl, target: tl, no_cap: no_cap)

    output.each_with_index do |line, i|
      res << '\n' if i > 0
      res << line[1]
    end
  end

  @[AC::Route::PUT("/deepl")]
  def deepl(sl : String = "zh", tl : String = "en", no_cap : Bool = false)
    @render_called = true
    res = @context.response

    res.status_code = 200
    res.content_type = "text/plain; charset=utf-8"

    text = request.body.not_nil!.gets_to_end
    output = Deepl.translate(text.lines, source: sl, target: tl, no_cap: no_cap)

    output.each_with_index do |line, i|
      res << '\n' if i > 0
      res << line[1]
    end
  end
end
