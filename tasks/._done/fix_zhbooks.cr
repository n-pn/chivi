require "./shared/bootstrap"

# CV::Nvinfo.query.each_with_cursor(20) do |nvinfo|
#   nvseeds = nvinfo.nvseeds.to_a
#   next if nvseeds.empty?

#   nvseeds.each do |zhbook|
#     zhbook.nvinfo = nvinfo
#     zhbook.zseed = CV::SeedUtil.map_id(zhbook.sname)
#     zhbook.fix_id!
#     zhbook.save!
#   end

#   nvinfo.update({zseed_ids: nvseeds.map(&.zseed).sort})
# end

CV::Ubmemo.query.each_with_cursor(20) do |ubmemo|
  ubmemo.lr_sname = "chivi"
  ubmemo.lr_zseed = CV::SeedUtil.map_id(ubmemo.lr_sname)
  ubmemo.save!
end
