require "./shared/bootstrap"

# CV::Nvinfo.query.each_with_cursor(20) do |nvinfo|
#   zhbooks = nvinfo.zhbooks.to_a
#   next if zhbooks.empty?

#   zhbooks.each do |zhbook|
#     zhbook.nvinfo = nvinfo
#     zhbook.zseed = CV::SeedUtil.map_id(zhbook.sname)
#     zhbook.fix_id!
#     zhbook.save!
#   end

#   nvinfo.update({zseed_ids: zhbooks.map(&.zseed).sort})
# end

CV::Ubmemo.query.each_with_cursor(20) do |ubmemo|
  ubmemo.lr_sname = "chivi"
  ubmemo.lr_zseed = CV::SeedUtil.map_id(ubmemo.lr_sname)
  ubmemo.save!
end
