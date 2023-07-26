require "sqlite3"
require "../src/_data/wndata/bgcata"

BOOK_DIR = "/2tb/var.chivi/zbook"

CHAP_DIR = "/2tb/var.chivi/zchap/globs"

struct Book
  include DB::Serializable

  getter s_bid : Int32
  getter pub_status : String
  getter updated_at : String
  getter chap_count : Int32
  getter latest_cid : String
end

def update_seed(sname : String)
  idx_dir = "#{CHAP_DIR}/#{sname}"
  puts idx_dir

  db_path = "sqlite3:#{BOOK_DIR}/#{sname[1..]}.db"
  books = DB.open(db_path, &.query_all(<<-SQL, as: Book))
    select id as s_bid, pub_status, updated_at, chap_count, latest_cid
    from books
  SQL

  books.each do |book|
    cata = Bgcata.new(sname, book.s_bid.to_s)
    cata.open_tx do |db|
      cata.insert_rlog!(
        db: db,
        total_chap: book.chap_count,
        latest_cid: book.latest_cid,
        status_str: book.pub_status,
        update_str: book.updated_at,
      )

      puts "create entry for #{cata.idx_path}"
    end
  end
end

ARGV.each do |sname|
  update_seed(sname)
end

# Dir.children(BOOK_DIR).each do |fname|
#   next unless fname.ends_with?(".db")
#   sname = "!" + File.basename(fname, ".db")
# end
