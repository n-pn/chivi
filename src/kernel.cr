require "chivi/main"
require "./kernel/*"

module Kernel
  extend self

  @@books = Array(BookFile).from_json File.read("data/txt0out/indexes/top-books.json")

  # TODO: filtering

  def book_size
    @@books.size
  end

  def list_books(limit = 24, offset = 0, sort_by = "updated_at")
    books = sort_books(sort_by)
    books[offset, limit]
  end

  def sort_books(sort_by : String)
    case sort_by
    when "tally"
      @@books.sort_by(&.tally.-)
    when "^tally"
      @@books.sort_by(&.tally)
    when "score"
      @@books.sort_by(&.score.-)
    when "^score"
      @@books.sort_by(&.score)
    when "votes"
      @@books.sort_by(&.votes.-)
    when "^votes"
      @@books.sort_by(&.votes)
    when "word_count"
      @@books.sort_by(&.word_count.-)
    when "^word_count"
      @@books.sort_by(&.word_count)
    when "updated_at"
      @@books.sort_by(&.updated_at.-)
    when "^updated_at"
      @@books.sort_by(&.updated_at)
    else
      @@books
    end
  end

  def find_book(slug : String)
    @@books.find(&.vi_slug.==(slug))
  end

  def list_chaps(book : String)
    if book = find_book(book)
      site = book.favor_scrap
      return [] of ChapFile if site.empty?
      bsid = book.scrap_links[site]

      file_tmp = "data/txt-tmp/chlists/#{bsid}.json"
      file_out = "data/txt-out/chlists/#{bsid}.json"
      if File.exists?(file_out)
        Array(Chap).from_json File.read(file_out)
      elsif

    return nil unless File.exists?(chap_file)
  end

  def load_text(book : String, slug : String)
    text_file = ".txt/texts/#{book}/#{slug}.txt"
    return nil unless File.exists?(text_file)
    File.read_lines(text_file)
  end
end
