# require "../../../libcv/qtran_data"
require "./_ctrl_base"

class CV::QtranData
  getter simps : Array(String) do
    @input.map { |x| MT::Engine.trad_to_simp(x) }
  end

  def make_engine(uname : String)
    MT::Engine.new(@dname, uname)
  end
end

module MT
  class QtranCtrl < BaseCtrl
    base "/_mt"

    @[AC::Route::POST("/convert")]
    def convert(book = "combine", rmode = "txt", apply_cap : Bool = true, has_title : Bool = false, use_temp : Bool = false)
      engine = Engine.new(book, temp: use_temp)
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

    @[AC::Route::POST("/tradsim")]
    def tradsim(input : String, config = "tw2s")
      output = Process.run("/usr/bin/opencc", {"-c", config}) do |proc|
        proc.input.print(input)
        proc.input.close
        proc.output.gets_to_end
      rescue err
        err.message
      end

      render text: output
    end
  end
end
