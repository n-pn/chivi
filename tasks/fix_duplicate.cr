require "./shared/bootstrap"

CV::Nvinfo.query.with_author.to_a.each do |nvinfo|
  old_btitle = nvinfo.zname
  old_author = nvinfo.author.zname

  fix_btitle, fix_author = CV::BookUtil.fix_names(old_btitle, old_author)
  next if old_btitle == fix_btitle && old_author == fix_author

  puts "- #{nvinfo.bhash}"
  puts "  btitle: #{old_btitle} => #{fix_btitle}" if old_btitle != fix_btitle
  puts "  author: #{old_author} => #{fix_author}" if old_author != fix_author

  if old_author == fix_author
    author = nvinfo.author
  else
    author = CV::Author.upsert!(fix_author)
  end

  new_nvinfo = CV::Nvinfo.upsert!(author, fix_btitle)
  nvinfo.update!({subdue_id: new_nvinfo.id})

  nvseeds = nvinfo.nvseeds.to_a.sort_by(&.zseed)
  nvseeds.each do |zhbook|
    next if zhbook.sname == "chivi" || zhbook.sname == "users"
    next if CV::Nvseed.find({nvinfo_id: new_nvinfo.id, zseed: zhbook.zseed})

    zhbook.nvinfo_id = new_nvinfo.id
    zhbook.fix_id!
    zhbook.save!
  end

  zseeds = new_nvinfo.nvseeds.to_a.map(&.zseed).sort
  new_nvinfo.update!({zseeds: zseeds})

  CV::Yscrit.query.where(nvinfo_id: nvinfo.id).to_update.set(nvinfo_id: new_nvinfo.id).execute
  CV::Ubmemo.query.where(nvinfo_id: nvinfo.id).to_update.set(nvinfo_id: new_nvinfo.id).execute
rescue err
  puts err
end
