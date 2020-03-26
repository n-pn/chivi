require "./book_file"

class BookRepo
  def initialize(@file = ".txt/top-books.json", preload = true)
    @books = {} of String => BookFile
    @sorts = {} of String => BookFile

    load! if preload
  end

  def load!
    books = Array(BookFile).from_json File.read(@file)
    books.each do |book|
      @books[book.vi_slug] = book
    end

    @sorts["tally"] = books.sort_by(&.tally.-)
    @sorts["^tally"] = books.sort_by(&.tally)
    @sorts["score"] = books.sort_by(&.score.-)
    @sorts["^score"] = books.sort_by(&.score)
    @sorts["votes"] = books.sort_by(&.votes.-)
    @sorts["^votes"] = books.sort_by(&.votes)
    @sorts["word_count"] = books.sort_by(&.word_count.-)
    @sorts["^word_count"] = books.sort_by(&.word_count)
    @sorts["updated_at"] = books.sort_by(&.updated_at.-)
    @sorts["^updated_at"] = books.sort_by(&.updated_at)
  end

  def total
    @books.size
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
end
