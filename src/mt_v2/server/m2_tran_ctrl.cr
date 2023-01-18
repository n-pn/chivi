# require "../../../libcv/qtran_data"
require "./_m2_ctrl_base"

class CV::QtranData
  getter simps : Array(String) do
    @input.map { |x| M2::Engine.trad_to_simp(x) }
  end

  def make_engine(uname : String)
    M2::Engine.new(@dname, uname)
  end
end

class M2::TranCtrl < AC::Base
  base "/_m2"

  @[AC::Route::POST("/convert")]
  def convert(udict = "combine",
              rmode = "txt",
              apply_cap : Bool = true,
              has_title : Bool = false,
              use_temp : Bool = false)
    engine = Engine.new(udict, temp: use_temp)
    to_mtl = rmode == "mtl"

    input = request.body.not_nil!.gets_to_end
    lines = input.split("\n").map!(&.strip)

    @render_called = true
    res = @context.response

    res.status_code = 200
    res.content_type = "text/plain; charset=utf-8"

    if title = lines.shift?
      # data = has_title ? engine.cv_title_full(title) : engine.cv_plain(title)
      data = engine.cv_plain(title)
      to_mtl ? data.to_mtl(res, apply_cap) : data.to_txt(res, apply_cap)
    end

    lines.each do |line|
      res << '\n'
      # puts line.colorize.yellow
      data = engine.cv_plain(line)
      to_mtl ? data.to_mtl(res, apply_cap) : data.to_txt(res, apply_cap)
    rescue err
      Log.error(exception: err) { line }
      res << "Lỗi máy dịch!"
    end
  end
end
