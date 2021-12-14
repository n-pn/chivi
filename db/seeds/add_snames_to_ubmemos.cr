CV::Ubmemo.query.order_by(id: :asc).each_with_cursor(20) do |ubmemo|
  ubmemo.lr_sname = CV::Zhseed.sname(ubmemo.lr_zseed)
  ubmemo.save!
end
