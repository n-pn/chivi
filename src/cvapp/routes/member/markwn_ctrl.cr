# require "../_ctrl_base"

# class CV::MarkBookCtrl < CV::BaseCtrl
#   base "/_db/_self/books"

#   @[AC::Route::Filter(:before_action, except: [:show])]
#   def ensure_logged_in
#     render :unauthorized if _privi < 0
#   end

#   @[AC::Route::GET("/access")]
#   def access(kind : String? = nil)
#     pg_no, limit, offset = _paginate(min: 15, max: 30)

#     query = Ubmemo.query.where("viuser_id = ?", _viuser.id)

#     case kind
#     when "marked" then query.where("locked = true")
#     when "stored" then query.where("status > 0")
#     end

#     query = query.order_by(utime: :desc).limit(limit).offset(offset)
#     render json: query.with_nvinfo.map { |x| UbmemoView.new(x, true) }
#   end

#   getter! book_mark : Ubmemo

#   @[AC::Route::Filter(:before_action, except: [:access])]
#   def get_book_mark(wn_id : Int32)
#     @book_mark = Ubmemo.find_or_new(_vu_id, wn_id)
#   end

#   @[AC::Route::GET("/:wn_id")]
#   def show(wn_id : Int32) : Nil
#     render json: UbmemoView.new(book_mark)
#   end

#   struct AccessData
#     include JSON::Serializable

#     getter sname : String, ch_no : Int16
#     getter cpart : Int16 = 1

#     getter title : String = ""
#     getter uslug : String = "-"

#     getter locking : Bool = false
#   end

#   @[AC::Route::PUT("/:wn_id/access", body: :data)]
#   def update_access(wn_id : Int64, data : AccessData)
#     book_mark.mark!(
#       data.sname, data.ch_no, data.cpart,
#       data.title, data.uslug, data.locking ? 1 : 0
#     )
#     render json: UbmemoView.new(book_mark)
#   end

#   record StatusForm, status : String = "default" do
#     include JSON::Serializable
#   end

#   @[AC::Route::PUT("/:wn_id/status", body: :form)]
#   def update_status(wn_id : Int64, form : StatusForm)
#     book_mark.update!({status: form.status})
#     render json: UbmemoView.new(book_mark)
#   end
# end
