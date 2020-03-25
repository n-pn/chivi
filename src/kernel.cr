require "chivi/main"
require "./kernel/models/*"

module Kernel
  extend self
  CHIVI = Engine::Main.new(".dic/")

  BOOKS = Array(Book).from_json File.read(".txt/top-books.json")

  # TODO: filtering

  def book_size
    BOOKS.size
  end

  def list_books(limit = 24, offset = 0, sort_by = "tally")
    books = sort_books(sort_by)
    books[offset, limit]
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

  def find_book(slug : String)
    BOOKS.find(&.vi_slug.==(slug))
  end

  def list_chaps(book : String)
    chap_file = ".txt/chaps/#{book}.json"
    return nil unless File.exists?(chap_file)
    Array(Chap).from_json File.read(chap_file)
  end

  def load_text(book : String, slug : String)
    text_file = ".txt/texts/#{book}/#{slug}.txt"
    return nil unless File.exists?(text_file)
    File.read_lines(text_file)
  end
end
