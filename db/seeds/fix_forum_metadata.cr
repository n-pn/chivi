include CV

Nvinfo.query.each do |nvinfo|
  topics = nvinfo.dtopics.to_a.reject(&.ii.== 0)
  next if topics.empty?

  nvinfo.dtopic_count = topics.size
  nvinfo.dt_view_count = topics.map(&.view_count).sum
  nvinfo.dt_post_utime = topics.map(&.utime).max
  nvinfo.save!

  topics.sort_by(&.id).each_with_index(1) do |dtopic, ii|
    dtopic.ii = ii

    if dtbody = Dtpost.find({dtopic_id: dtopic.id, ii: 0})
      dtopic.dtbody_id = dtbody.id
    end

    dtopic.save!
  end
end
