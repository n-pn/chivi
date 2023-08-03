require "../shared/bootstrap"

def transfer(old_nvinfo, new_nvinfo)
  old_bid = old_nvinfo.id
  new_bid = new_nvinfo.id

  old_nvinfo.update!({subdue_id: new_bid})

  zseeds = old_nvinfo.zseeds - new_nvinfo.zseeds
  return if zseeds.empty?

  query = CV::Chroot.query
    .where(nvinfo_id: old_bid)
    .where("zseed in ?", zseeds)

  query.each do |nvseed|
    nvseed.nvinfo_id = new_bid
    nvseed.fix_ix!
    nvseed.save!
  end

  zseeds = new_nvinfo.nvseeds.to_a.map(&.zseed).sort!
  new_nvinfo.update!({zseeds: zseeds})

  CV::Yscrit.query.where(nvinfo_id: old_bid).to_update.set(nvinfo_id: new_bid).execute
  CV::Ubmemo.query.where(nvinfo_id: old_bid).to_update.set(nvinfo_id: new_bid).execute
end

changed_author = {} of String => String
changed_btitle = {} of String => String

CV::Wninfo.query.with_author.to_a.each do |nvinfo|
  old_btitle = nvinfo.zname
  old_author = nvinfo.author.zname

  fix_btitle, fix_author = CV::BookUtil.fix_names(old_btitle, old_author)
  next if old_btitle == fix_btitle && old_author == fix_author

  puts "- #{nvinfo.btitle_vi}"
  puts "  btitle: #{old_btitle} => #{fix_btitle}" if old_btitle != fix_btitle
  puts "  author: #{old_author} => #{fix_author}" if old_author != fix_author

  if old_author == fix_author
    author = nvinfo.author
  else
    author = CV::Author.upsert!(fix_author)
  end

  new_nvinfo = CV::Wninfo.upsert!(author, fix_btitle)

  changed_author[old_author] = fix_author if old_author != fix_author
  changed_btitle[old_btitle] = fix_btitle if old_btitle != fix_btitle

  transfer(nvinfo, new_nvinfo)
rescue err
  puts err
end

def write_change(file : String, data : Hash(String, String))
  File.open(file, "w") do |io|
    data.each { |k, v| io << k << '\t' << v << '\n' }
  end
end

DIR = "db/seed_data/wninfos"
write_change("#{DIR}/author_changes.tsv", changed_author)
write_change("#{DIR}/btitle_changes.tsv", changed_btitle)
