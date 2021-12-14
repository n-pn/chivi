CV::Zhbook.query.order_by(id: :asc).each_with_cursor(20) do |zhbook|
  zhbook.sname = CV::Zhseed.sname(zhbook.zseed)
  zhbook.save!
end
