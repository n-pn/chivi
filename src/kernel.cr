require "chivi/main"
require "./models/*"

module Kernel
  extend self
  CHIVI = Chivi::Main.new(".dic/")

  BOOKS = Array(Book).from_json File.read(".txt/top-books.json")

  # alias SortBy = Symbol | Tuple(Symbol, Symbol)

  def list_books(limit = 20, offset = 0, sort_by = "tally")
    books = sort_books(sort_by)
    books[0, 20]
  end

  def sort_books(sort_by = "updated_at")
    case sort_by
    when "tally"
      BOOKS.sort_by(&.tally.-)
    when "^tally"
      BOOKS.sort_by(&.tally)
    when "score"
      BOOKS.sort_by(&.score.-)
    when "^score"
      BOOKS.sort_by(&.score)
    when "votes"
      BOOKS.sort_by(&.votes.-)
    when "^votes"
      BOOKS.sort_by(&.votes)
    when "word_count"
      BOOKS.sort_by(&.word_count.-)
    when "^word_count"
      BOOKS.sort_by(&.word_count)
    when "updated_at"
      BOOKS.sort_by(&.updated_at.-)
    when "^updated_at"
      BOOKS.sort_by(&.updated_at)
    else
      BOOKS
    end
  end

  def parse_page(str, limit = 20)
    int = parse_int(str)
    int = 1 if int < 1

    offset = (int - 1) * limit
    {limit, offset}
  end

  def parse_int(str)
    str.to_i
  rescue
    0
  end
end
