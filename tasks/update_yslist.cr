require "./shared/bootstrap"

CV::Yslist.query.each do |yslist|
  book = yslist.nvinfos.to_a

  genres = book.flat_map(&.vgenres)
  yslist.genres = genres.tally.to_a.sort_by!(&.[1].-).map(&.[0])

  yslist.covers = book.sort_by(&.weight.-).first(3).map(&.bcover)

  yslist.set_name(yslist.zname)
  yslist.set_desc(yslist.zdesc)

  yslist.save!
end
