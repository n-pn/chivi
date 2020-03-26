require "json"

class Kernel::Book
  include JSON::Serializable

  property zh_slug : String
  property vi_slug : String

  property zh_title : String
  property vi_title : String

  property zh_author : String
  property vi_author : String

  property zh_intro : String
  property vi_intro : String

  property zh_genre : String
  property vi_genre : String

  property zh_tags : Array(String)
  property vi_tags : Array(String)

  property covers : Array(String)

  property status : Int32
  property hidden : Int32

  property votes : Int32
  property score : Float64
  property tally : Float64

  property word_count : Int32
  property chap_count : Int32

  property review_count : Int32

  property updated_at : Int64

  property _yousuu_bids : Array(Int32)
  property _origin_urls : Array(String)
  property _scrap_sites : Array(String)
  property _scrap_bsids : Array(String)

  @@books : Array(Book)? = nil

  def self.books
    @@books ||= Array(Book).from_json File.read(".txt/top-books.json")
  end

  def self.total
    books.size
  end

  def self.list(limit = 20, offset = 0, sort_by = "updated_at")
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

  def self.each(sort_by : String)
    sort(books, sort_by).each do |book|
      yield book
    end
  end

  def self.sort(books, sort_by : String)
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
