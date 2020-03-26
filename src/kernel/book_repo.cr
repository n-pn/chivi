class BookRepo
  def initialize(@file = ".txt/top-books.json", preload = true)
    @books = {} of String => BookFile

    load! if preload
  end

  def load!
    books = Array(BookFile).from_json File.read(@file)
  end

  def total
    books.size
  end

  def list(limit = 20, offset = 0, sort_by = "updated_at")
    res = [] of Book
    each(sort_by) do
      if offset > 0
        offset -= 1
      else
        res << book
        limit -= 1
        break if limit == 0
      end
    end

    res
  end

  def each(sort_by : String)
    sort(books, sort_by).each do |book|
      yield book
    end
  end

  def sort(books, sort_by : String)
    case sort_by
    when "tally"
      books.sort_by(&.tally.-)
    when "^tally"
      books.sort_by(&.tally)
    when "score"
      books.sort_by(&.score.-)
    when "^score"
      books.sort_by(&.score)
    when "votes"
      books.sort_by(&.votes.-)
    when "^votes"
      books.sort_by(&.votes)
    when "word_count"
      books.sort_by(&.word_count.-)
    when "^word_count"
      books.sort_by(&.word_count)
    when "updated_at"
      books.sort_by(&.updated_at.-)
    when "^updated_at"
      books.sort_by(&.updated_at)
    else
      books
    end
  end
end
