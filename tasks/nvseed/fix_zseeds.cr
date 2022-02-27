require "../shared/bootstrap"

CV::Nvinfo.query.each do |nvinfo|
  zhbooks = nvinfo.zhbooks.to_a.reject(&.zseed.== 0)

  zseeds = [] of Int32
  zhbooks.group_by(&.sname).each do |sname, items|
    items.sort_by!(&.created_at)
    zhbook = items.shift

    unless items.empty?
      puts [sname, zhbook.zseed, "<-", items.map(&.zseed)]
      CV::Zhbook.query.where(id: items.map(&.id)).to_delete.execute
    end

    zhbook.zseed = CV::SeedUtil.map_id(sname)
    zhbook.fix_id!
    zhbook.save!

    zseeds << zhbook.zseed
  end

  nvinfo.update!({zseed_ids: zseeds.sort})
end
