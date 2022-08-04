require "./shared/bootstrap"

DIR = "var/fixed"
Dir.mkdir_p(DIR)

def map_user_ids
  out_path = Path[DIR, "users.tsv"]
  out_file = File.open(out_path, "w")

  CV::Viuser.query.order_by(id: :asc).each do |user|
    sn_id = (user.id + 10) * 2
    infos = {user.uname, sn_id, user.id, user.email, user.privi}
    out_file.puts infos.join('\t')
  end

  out_file.close
end

def map_book_ids
  out_path = Path[DIR, "books.tsv"]
  out_file = File.open(out_path, "w")

  CV::Nvinfo.query.order_by(id: :asc).with_btitle.with_author.each do |book|
    infos = {book.bhash, book.id, book.bslug, book.btitle.zname, book.author.zname}
    out_file.puts infos.join('\t')
  end

  out_file.close
end

map_user_ids
map_book_ids
