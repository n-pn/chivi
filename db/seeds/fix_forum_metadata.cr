include CV

Nvinfo.query.each do |nvinfo|
  # next if nvinfo.dtopic_count == 0
  # Dtopic.init_base_topic!(nvinfo) if nvinfo.id > 0

  topics = Dtopic.query.where({nvinfo_id: nvinfo.id}).to_a
  next if topics.empty?

  nvinfo.dtopic_count = topics.size
  nvinfo.dt_view_count = topics.map(&.view_count).sum
  nvinfo.dt_post_utime = topics.map(&.utime).max
  nvinfo.save!

  topics.sort_by(&.id).each_with_index(1) do |dtopic, ii|
    dtopic_ii = nvinfo.dt_ii + ii

    dtbody = dtopic.dtbody
    unless dtbody.id_column.defined?
      dtbody.cvuser_id = dtopic.cvuser_id
      dtbody.save!
    end

    dtopic.update!({ii: dtopic_ii.to_i, dtbody_id: dtbody.id})
  end
end
