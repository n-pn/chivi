require "./_m1_ctrl_base"
require "./m1_term_view"

class M1::M1TermCtrl < AC::Base
  base "/_m1/terms"

  @[AC::Route::POST("/query", body: :words)]
  def lookup(words : Array(String), vd_id : Int32)
    w_udic = cookies["w_udic"]?.try(&.value) != "f"
    render json: M1TermView.new(words, wn_id: vd_id, uname: _uname, w_udic: w_udic)
  end

  @[AC::Route::POST("/batch")]
  def upsert_batch
    render :method_not_allowed, text: "Chức năng đang hoàn thiện!"
  end
end
