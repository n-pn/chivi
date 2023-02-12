require "./_m1_ctrl_base"

require "../data/v1_dict"
require "../core/m1_core"

class M1::TranCtrl < AC::Base
  base "/_m1/qtran"

  enum RenderTitle
    None; First; All
  end

  @[AC::Route::POST("/cv_chap")]
  def cv_chap(wn_id : Int32 = 0, cv_title : String = "none", label : String? = nil)
    w_temp = cookies["w_temp"]?.try(&.value) || "t"
    engine = MtCore.generic_mtl(wn_id, temp: w_temp == "t", user: _uname)

    input = request.body.not_nil!.gets_to_end
    render_title = RenderTitle.parse(cv_title)

    output = String.build do |str|
      stime = Time.monotonic

      iter = input.each_line
      head = iter.next.as(String)

      mtl = !render_title.none? ? engine.cv_title(head) : engine.cv_plain(head)
      mtl.to_mtl(str)

      str << '\t' << ' ' << label if label

      iter.each do |line|
        str << '\n'

        mtl = render_title.all? ? engine.cv_title(line) : engine.cv_plain(line)
        mtl.to_mtl(str)
      end

      tspan = (Time.monotonic - stime).total_milliseconds.round.to_i

      vdict = DbDict.load(wn_id)

      str << "\n$\t$\t$\n" << tspan << '\t' << vdict.term_avail << '\t' << vdict.dname
    end

    render text: output
  end
end
