# require "../../../libcv/qtran_data"
require "./_mt_ctrl_base"

class MT::TranCtrl < AC::Base
  base "/_ai"

  # @[AC::Route::POST("/qtran")]
  # def qtran(udict : Int32, format : String = "txt", apply_cap : Bool = true)
  #   w_udic = cookies["w_udic"]?.try(&.value) || "f"

  #   engine = Engine.new(udict, user: _uname, temp: w_udic == "t")
  #   to_mtl = format == "mtl"

  #   input = request.body.not_nil!.gets_to_end
  #   lines = input.split("\n", remove_empty: true).map!(&.strip)

  #   @render_called = true
  #   res = @context.response

  #   res.status_code = 200
  #   res.content_type = "text/plain; charset=utf-8"

  #   if title = lines.shift?
  #     # data = has_title ? engine.cv_title_full(title) : engine.cv_plain(title)
  #     data = engine.cv_plain(title)
  #     to_mtl ? data.to_mtl(res, apply_cap) : data.to_txt(res, apply_cap)
  #   end

  #   lines.each do |line|
  #     res << '\n'
  #     # puts line.colorize.yellow
  #     data = engine.cv_plain(line)
  #     to_mtl ? data.to_mtl(res, apply_cap) : data.to_txt(res, apply_cap)
  #   rescue err
  #     Log.error(exception: err) { line }
  #     res << "Lỗi máy dịch!"
  #   end
  # end
end
