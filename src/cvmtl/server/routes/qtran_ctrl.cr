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
    def convert(input : String, book : String = "combine",
                theme : String? = nil, user : String? = nil,
                rmode : String = "txt", apply_cap : Bool = true)
      engine = Engine.new(book, theme, user)
      mtdata = engine.cv_plain(input, apply_cap)

      render text: rmode == "txt" ? mtdata.to_txt : mtdata.to_mtl
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
