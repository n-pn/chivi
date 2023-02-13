require "./_m1_ctrl_base"
require "./m1_term_view"

class M1::M1TermCtrl < AC::Base
  base "/_m1/terms"

  @[AC::Route::POST("/query", body: :words)]
  def lookup(words : Array(String), dname : String = "combine")
    wn_id = DbDict.get_id(dname)
    render json: M1TermView.new(words, wn_id)
  end

  @[AC::Route::POST("/batch")]
  def upsert_batch
    render :method_not_allowed, text: "Chức năng đang hoàn thiện!"
  end
end
