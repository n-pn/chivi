CV::Zhbook.query.each_with_cursor(20) do |zhbook|
  zhbook.zseed = CV::NvSeed.map_id(zhbook.sname)
  zhbook.save!
end
