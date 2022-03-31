require "../shared/bootstrap"

CV::Nvinfo.query.each do |nvinfo|
  zhbooks = nvinfo.zhbooks.to_a

  zseeds = [] of Int32
  zhbooks.group_by(&.sname).each do |sname, items|
    items.sort_by!(&.created_at)

    zhbook = items.shift
    zhbook.zseed = CV::SnameMap.map_int(sname)
    zseeds << zhbook.zseed

    unless items.empty?
      puts "#{nvinfo.bslug}: #{zhbook.id} <- #{items.map(&.id)}"
      CV::Nvseed.query.where(id: items.map(&.id)).to_delete.execute
    end

    ix = CV::Nvseed.map_ix(nvinfo.id, zhbook.zseed)
    if zhbook.ix != ix
      puts "update_id: [#{nvinfo.id}, #{zhbook.zseed}] #{zhbook.ix} => #{ix}"
      zhbook.update!({ix: ix})
    end
  end

  nvinfo.update!({zseed_ids: zseeds.sort})
end
