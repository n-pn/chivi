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

  @[AC::Route::PUT("/hanviet", body: :input)]
  def hanviet(input : String, mode : String = "mtl", cap_first : Bool = true)
    @render_called = true
    res = @context.response

    res.status_code = 200
    res.content_type = "text/plain; charset=utf-8"

    engine = Engine.hanviet

    input.lines.each_with_index do |line, idx|
      res << '\n' if idx > 0
      data = engine.convert(line)
      mode == "txt" ? data.to_txt(res, cap: cap_first) : data.to_mtl(res, cap: cap_first)
    end
  end

  @[AC::Route::PUT("/btran", body: :input)]
  def btran(input : String, lang : String = "vi", no_cap : Bool = false)
    @render_called = true
    res = @context.response

    res.status_code = 200
    res.content_type = "text/plain; charset=utf-8"

    output = Btran.translate(input.lines, lang: lang, no_cap: no_cap)

    output.each_with_index do |line, i|
      res << '\n' if i > 0
      res << line[1]
    end
  end

  @[AC::Route::PUT("/deepl", body: :input)]
  def deepl(input : String, no_cap : Bool = false)
    @render_called = true
    res = @context.response

    res.status_code = 200
    res.content_type = "text/plain; charset=utf-8"

    output = Deepl.translate(input.lines, no_cap: no_cap)

    output.each_with_index do |line, i|
      res << '\n' if i > 0
      res << line[1]
    end
  end
end
