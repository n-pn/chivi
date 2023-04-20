require "../_ctrl_base"

# require "../../views/wninfo_view"

class CV::AuthorCtrl < CV::BaseCtrl
  @[AC::Route::GET("/authors/:id/books")]
  def books(id : Int64)
    books = Wninfo.query.where("author_id = ?", id).to_a
    pg_no, limit, offset = _paginate(min: 10, max: 50)

    render json: {
      total: books.size,
      pgidx: pg_no,
      pgmax: _pgidx(books.size, limit),
      books: books[offset, limit].map { |x| WninfoView.new(x, false) },
    }
  end
end
