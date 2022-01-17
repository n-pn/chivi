require "./base_ctrl"

class CV::AuthorCtrl < CV::BaseCtrl
  private def extract_params
    page = params.fetch_int("page", min: 1)
    take = params.fetch_int("take", min: 1, max: 25)
    {page, take, (page - 1) * take}
  end

  def books
    pgidx, limit, offset = extract_params

    author_id = params["author_id"].to_i64
    author = Author.load!(author_id)

    books = author.books
    total = books.size

    response.headers.add("Cache-Control", "public, min-fresh=180")

    json_view({
      total: total,
      pgidx: pgidx,
      pgmax: (total - 1) // limit + 1,
      books: books[offset, limit].map { |x| NvinfoView.new(x, false) },
    })
  rescue err
    puts err.inspect_with_backtrace
    halt! 500, err.message
  end
end
