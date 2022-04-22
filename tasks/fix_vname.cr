require "./shared/bootstrap"

CV::Yslist.query.each do |yslist|
  yslist.set_name(yslist.zname)
  yslist.save!
end
