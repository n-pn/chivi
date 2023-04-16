require "../_ctrl_base"

# require "../../views/wninfo_view"

class CV::AuthorCtrl < CV::BaseCtrl
  @[AC::Route::GET("/authors/:id/books", converters: {lm: ConvertLimit})]
  def books(id : Int64, pg pgidx : Int32 = 1, lm limit : Int32 = 24)
    books = Wninfo.query.where("author_id = ?", id).to_a

    limit = 24 if limit < 24
    offset = CtrlUtil.offset(pgidx, limit)

    render json: {
      total: books.size,
      pgidx: pgidx,
      pgmax: _pgidx(books.size, limit),
      books: books[offset, limit].map { |x| WninfoView.new(x, false) },
    }
  end
end
