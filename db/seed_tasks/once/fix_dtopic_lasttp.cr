module CV
  Cvpost.query.each do |dtopic|
    dtpost = Cvrepl.query.find!({dtopic_id: dtopic.id, ii: dtopic.post_count})
    dtopic.lasttp_id = dtpost.id
    dtopic.save!
  end
end
