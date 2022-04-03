require "./shared/bootstrap"

# CV::Nvinfo.query.each_with_cursor(20) do |nvinfo|
#   nvseeds = nvinfo.nvseeds.to_a
#   next if nvseeds.empty?

#   nvseeds.each do |nvseed|
#     nvseed.nvinfo = nvinfo
#     nvseed.zseed = CV::SeedUtil.map_id(nvseed.sname)
#     nvseed.fix_id!
#     nvseed.save!
#   end

#   nvinfo.update({zseeds: nvseeds.map(&.zseed).sort})
# end

CV::Ubmemo.query.each_with_cursor(20) do |ubmemo|
  ubmemo.lr_sname = "chivi"
  ubmemo.lr_zseed = CV::SeedUtil.map_id(ubmemo.lr_sname)
  ubmemo.save!
end
