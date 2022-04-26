require "./shared/bootstrap"

CV::Nvinfo.query.order_by(id: :asc).each do |nvinfo|
  nvinfo.btitle = CV::Btitle.upsert!(nvinfo.zname)
  nvinfo.save!
end
