require "./stores/*"

module CV::Marked
  extend self

  DIR = "_db/marked"
  ::FileUtils.mkdir_p("#{DIR}/book-users")
  ::FileUtils.mkdir_p("#{DIR}/user-books")
  ::FileUtils.mkdir_p("#{DIR}/user-seeds")
  ::FileUtils.mkdir_p("#{DIR}/user-chaps")

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
    USER_BOOKS[uname] ||= TokenMap.new(map_path("user-books/#{uname}"))
  end

  def book_users(b_hash : String)
    BOOK_USERS[b_hash] ||= TokenMap.new(map_path("book-users/#{b_hash}"))
  end

  def user_seeds(uname : String)
    USER_SEEDS[uname] ||= ValueMap.new(map_path("user-seeds/#{uname}"))
  end

  def user_chaps(uname : String)
    USER_CHAPS[uname] ||= ValueMap.new(map_path("user-chaps/#{uname}"))
  end

  def all_user_books(uname : String, bmark : String)
    user_books(uname).keys(bmark)
  end

  def all_book_users(b_hash : String, bmark : String)
    book_users(b_hash).keys(bmark)
  end

  def mark_book(uname : String, b_hash : String, bmark : String) : Nil
    user_books(uname).tap(&.add(b_hash, [bmark])).save!(mode: :upds)
    book_users(b_hash).tap(&.add(uname, [bmark])).save!(mode: :upds)
  end

  def unmark_book(uname : String, b_hash : String) : Nil
    user_books(uname).tap(&.rem(b_hash)).save!(mode: :upds)
    user_books(b_hash).tap(&.rem(uname)).save!(mode: :upds)
  end
end
