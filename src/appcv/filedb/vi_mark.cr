require "../../tsvfs/*"

module CV::ViMark
  extend self

  DIR = "_db/vi_users"
  ::FileUtils.mkdir_p("#{DIR}/marks")
  ::FileUtils.mkdir_p("#{DIR}/books")
  ::FileUtils.mkdir_p("#{DIR}/seeds")
  ::FileUtils.mkdir_p("#{DIR}/chaps")

  MAKRS = {} of String => TokenMap
  BOOKS = {} of String => TokenMap

  SEEDS = {} of String => OrderMap
  CHAPS = {} of String => OrderMap

  def save!(mode : Symbol = :full)
    MAKRS.each_value(&.save!(mode: mode))
    BOOKS.each_value(&.save!(mode: mode))

    SEEDS.each_value(&.save!(mode: mode))
    CHAPS.each_value(&.save!(mode: mode))
  end

  def mark_map(bname : String)
    MAKRS[bname] ||= TokenMap.new("#{DIR}/marks/#{bname}.tsv")
  end

  def book_map(uname : String)
    BOOKS[uname] ||= TokenMap.new("#{DIR}/books/#{uname}.tsv")
  end

  def seed_map(uname : String)
    SEEDS[uname] ||= OrderMap.new("#{DIR}/seeds/#{uname}.tsv")
  end

  def chap_map(uname : String)
    CHAPS[uname] ||= OrderMap.new("#{DIR}/chaps/#{uname}.tsv")
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

  def mark_chap(uname : String, bname : String, zseed : String,
                chidx : String, title : String, uslug : String)
    atime = Time.utc.to_unix.//(60).to_s
    chap_mark = ViMark.chap_map(uname)
    chap_mark.set!(bname, [atime, zseed, chidx, title, uslug])
    chap_mark.save!(clean: false)
  end
end
