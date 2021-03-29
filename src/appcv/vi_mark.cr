require "../tabkv/*"

module CV::ViMark
  extend self

  DIR = "_db/vi_users"
  ::FileUtils.mkdir_p("#{DIR}/books")
  ::FileUtils.mkdir_p("#{DIR}/marks")

  USER_BOOKS = {} of String => TokenMap
  BOOK_USERS = {} of String => TokenMap

  USER_SEEDS = {} of String => ValueMap
  USER_CHAPS = {} of String => ValueMap

  def save!(mode : Symbol = :full)
    USER_BOOKS.each_value(&.save!(mode: mode))
    BOOK_USERS.each_value(&.save!(mode: mode))

    USER_SEEDS.each_value(&.save!(mode: mode))
    USER_CHAPS.each_value(&.save!(mode: mode))
  end

  def map_path(label : String)
    "#{DIR}/#{label}.tsv"
  end

  def user_books(uname : String)
    USER_BOOKS[uname] ||= TokenMap.new(map_path("marks/#{uname}"))
  end

  def book_users(bhash : String)
    BOOK_USERS[bhash] ||= TokenMap.new(map_path("books/#{bhash}"))
  end

  def all_user_books(uname : String, bmark : String)
    user_books(uname).keys(bmark)
  end

  def all_book_users(bhash : String, bmark : String)
    book_users(bhash).keys(bmark)
  end

  def mark_book(uname : String, bhash : String, bmark : String) : Nil
    user_books(uname).tap(&.set!(bhash, [bmark])).save!(clean: false)
    book_users(bhash).tap(&.set!(uname, [bmark])).save!(clean: false)
  end

  def unmark_book(uname : String, bhash : String) : Nil
    user_books(uname).tap(&.delete!(bhash)).save!(clean: false)
    user_books(bhash).tap(&.delete!(uname)).save!(clean: false)
  end
end
