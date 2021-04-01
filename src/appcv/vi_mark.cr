require "../tabkv/*"

module CV::ViMark
  extend self

  DIR = "_db/vi_users"
  ::FileUtils.mkdir_p("#{DIR}/marks")
  ::FileUtils.mkdir_p("#{DIR}/books")
  ::FileUtils.mkdir_p("#{DIR}/seeds")
  ::FileUtils.mkdir_p("#{DIR}/chaps")

  MAKRS = {} of String => TokenMap
  BOOKS = {} of String => TokenMap

  SEEDS = {} of String => ValueMap
  CHAPS = {} of String => ValueMap

  def save!(mode : Symbol = :full)
    MAKRS.each_value(&.save!(mode: mode))
    BOOKS.each_value(&.save!(mode: mode))

    SEEDS.each_value(&.save!(mode: mode))
    CHAPS.each_value(&.save!(mode: mode))
  end

  def load_map(label : String) : TokenMap
    TokenMap.new("#{DIR}/#{label}.tsv")
  end

  def mark_map(uname : String)
    MAKRS[uname] ||= load_map("marks/#{uname}")
  end

  def book_map(bname : String)
    BOOKS[bname] ||= load_map("books/#{bname}")
  end

  def seed_map(uname : String)
    SEEDS[uname] ||= load_map("seeds/#{uname}")
  end

  def info_map(bname : String)
    CHAPS[bname] ||= load_map("chaps/#{bname}")
  end

  def all_marks(bname : String, bmark : String)
    mark_map(bname).keys(bmark)
  end

  def all_books(uname : String, bmark : String)
    book_map(uname).keys(bmark)
  end

  def mark_book(uname : String, bname : String, bmark : String = "") : Nil
    if bmark.empty?
      book_map(uname).tap(&.delete!(bname)).save!(clean: false)
      mark_map(bname).tap(&.delete!(uname)).save!(clean: false)
    else
      book_map(uname).tap(&.set!(bname, [bmark])).save!(clean: false)
      mark_map(bname).tap(&.set!(uname, [bmark])).save!(clean: false)
    end
  end
end
