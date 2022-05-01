require "../shared/bootstrap"

CV::Nvinfo.query.each do |nvinfo|
  nvseeds = nvinfo.nvseeds.to_a

  zseeds = [] of Int32
  nvseeds.group_by(&.sname).each do |sname, items|
    items.sort_by!(&.created_at)

    nvseed = items.shift

    nvseed.zseed = CV::SnameMap.map_int(sname)
    zseeds << nvseed.zseed

    unless items.empty?
      puts "#{nvinfo.bslug}: #{nvseed.id} <- #{items.map(&.id)}"
      CV::Nvseed.query.where(id: items.map(&.id)).to_delete.execute
    end

    new_uid = CV::SnameMap.map_uid(nvinfo.id, nvseed.zseed)
    next if nvseed.uid == new_uid

    puts "update_uid: [#{nvinfo.id}, #{nvseed.sname}] #{nvseed.uid} => #{new_uid}"
    nvseed.update!(uid: new_uid)
  end

  nvinfo.update!({zseeds: zseeds.sort})
end
