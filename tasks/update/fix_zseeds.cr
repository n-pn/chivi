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

    ix = CV::Nvseed.map_ix(nvinfo.id, nvseed.zseed)
    if nvseed.ix != ix
      puts "update_id: [#{nvinfo.id}, #{nvseed.zseed}] #{nvseed.ix} => #{ix}"
      nvseed.update!({ix: ix})
    end
  end

  nvinfo.update!({zseeds: zseeds.sort})
end
