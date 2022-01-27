CV::Dboard.query.each do |dboard|
  next if dboard.id < 1

  nvinfo = CV::Nvinfo.find!({id: dboard.id})

  dboard.bname = nvinfo.vname
  dboard.bslug = nvinfo.bslug

  dboard.save!
end
