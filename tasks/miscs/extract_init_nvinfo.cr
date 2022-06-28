require "../shared/bootstrap"
require "../../src/_init/books/book_info"

module CV
  extend self

  Nvinfo.query.each do |nvinfo|
    save_base(nvinfo)
  end

  def save_base(nvinfo : Nvinfo)
    output = BookInfo.new("var/books/infos/=base/#{nvinfo.bhash}.tsv")

    output.set_btitle(nvinfo.btitle.zname)
    output.set_author(nvinfo.author.zname)

    output.set_bintro(nvinfo.zintro.split('\n'))
    output.set_genres(nvinfo.vgenres.map { |x| GenreMap.vi_to_zh(x) })
    output.set_bcover(nvinfo.scover)

    output.set_status(nvinfo.status)
    output.set_mftime(nvinfo.utime)

    output.save!
  end
end
