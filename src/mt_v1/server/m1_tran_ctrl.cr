require "./_m1_ctrl_base"
require "./m1_tran_data"

class M1::TranCtrl < AC::Base
  base "/_m1/qtran"

  @w_temp : Bool = false
  @w_init : Bool = false

  @[AC::Route::Filter(:before_action)]
  def before_action
    @w_temp = _read_cookie("w_temp").try(&.starts_with?('t')) || false
    @w_init = _read_cookie("w_init").try(&.starts_with?('t')) || false
  end

  @[AC::Route::POST("/")]
  def cv_post(wn_id : Int32 = 0, format = "mtl")
    input = request.body.try(&.gets_to_end) || ""

    # limit = 2 ** (_privi &+ 1) * 1000 &+ 1000

    # if input.size > limit
    #   render :bad_request, "Nội dung vượt quá giới hạn cho phép (#{input.size}/#{limit})"
    #   return
    # end

    qtran = TranData.new(input.lines, wn_id, format)
    cvmtl = qtran.cv_wrap(_uname, @w_temp, @w_init) { |io, engine| cv_post(io, engine) }

    render text: cvmtl
  end

  @[AC::Route::GET("/cached")]
  def cached(type : String, name : String, wn_id : Int32 = 0, format = "mtl")
    qtran = TranData.load_cached(type, name, wn_id, format)
    cvmtl = qtran.cv_wrap(_uname, @w_temp, @w_init) { |io, engine| cv_post(io, engine) }

    render json: {
      cvmtl: cvmtl,
      ztext: qtran.lines.join('\n'),
    }
  end

  @[AC::Route::POST("/cv_chap")]
  def cv_chap(wn_id : Int32 = 0, w_title : Bool = true, label : String? = nil)
    input = request.body.try(&.gets_to_end) || ""
    qtran = TranData.new(input.lines, wn_id, format: "mtl")

    cvmtl = qtran.cv_wrap(_uname, @w_temp, @w_init) do |io, engine|
      cv_chap(io, engine, w_title, label)
    end

    render text: cvmtl
  end

  @[AC::Route::POST("/tl_mulu")]
  def tl_mulu(wn_id : Int32 = 0)
    input = request.body.try(&.gets_to_end) || ""
    cvter = MtCore.init(wn_id)

    lines = String.build do |str|
      input.each_line do |line|
        cvter.cv_title(line).to_txt(str) unless line.empty?
        str << '\n'
      end
    end

    render text: lines
  end
end
