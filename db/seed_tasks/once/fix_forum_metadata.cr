include CV

Nvinfo.query.each do |nvinfo|
  # next if nvinfo.cvpost_count == 0
  # Cvpost.init_base_topic!(nvinfo) if nvinfo.id > 0

  topics = Cvpost.query.where({nvinfo_id: nvinfo.id}).to_a
  next if topics.empty?

  nvinfo.post_count = topics.size
  nvinfo.view_count = topics.map(&.view_count).sum
  nvinfo.board_bump = topics.map(&.utime).max
  nvinfo.save!

  topics.sort_by(&.id).each_with_index(1) do |cvpost, ii|
    cvpost_ii = nvinfo.dt_ii + ii

    cvrepl = cvpost.cvrepl
    unless cvrepl.id_column.defined?
      cvrepl.cvuser_id = cvpost.cvuser_id
      cvrepl.save!
    end

    cvpost.update!({ii: cvpost_ii.to_i, cvrepl_id: cvrepl.id})
  end
end
