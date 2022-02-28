require "../shared/bootstrap"

CV::Nvinfo.query.order_by(id: :desc).each do |nvinfo|
  zhbooks = nvinfo.zhbooks.to_a

  zseeds = [] of Int32
  zhbooks.group_by(&.sname).each do |sname, items|
    items.sort_by!(&.created_at)

    zhbook = items.shift
    zhbook.zseed = CV::SnameMap.map_int(sname)

    unless items.empty?
      puts nvinfo.bslug, "#{nvinfo.blsug}: #{zhbook.id} <- #{items.map(&.id)}"
      CV::Zhbook.query.where(id: items.map(&.id)).to_delete.execute
    end

    zhbook.tap(&.fix_id!).save!
    zseeds << zhbook.zseed
  end

  nvinfo.update!({zseed_ids: zseeds.sort})
end
