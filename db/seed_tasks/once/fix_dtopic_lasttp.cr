module CV
  Cvpost.query.each do |cvpost|
    cvrepl = Cvrepl.query.find!({cvpost_id: cvpost.id, ii: cvpost.repl_count})
    cvpost.lasttp_id = cvrepl.id
    cvpost.save!
  end
end
