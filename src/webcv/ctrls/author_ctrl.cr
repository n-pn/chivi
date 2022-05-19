class CV::AuthorCtrl < CV::BaseCtrl
  def books
    pgidx, limit, offset = Params.page_info(max: 25)

    author_id = params["author_id"].to_i64
    author = Author.load!(author_id)

    books = author.books
    total = books.size

    set_cache maxage: 180

    send_json({
      total: total,
      pgidx: pgidx,
      pgmax: CtrlUtil.pgmax(total, limit),
      books: books[offset, limit].map { |x| NvinfoView.new(x, false) },
    })
  end
end
