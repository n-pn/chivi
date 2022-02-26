require "../shared/bootstrap"

CV::Nvinfo.query.each do |nvinfo|
  zhbooks = nvinfo.zhbooks.to_a.reject(&.zseed.== 0)
  zhbooks.each do |zhbook|
    zhbook.zseed = CV::NvSeed.map_id(zhbook.sname)
    zhbook.fix_id!
    zhbook.save!
  end

  nvinfo.update!({zseed_ids: zhbooks.map(&.zseed).sort})
end
