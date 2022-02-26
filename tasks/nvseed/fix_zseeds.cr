require "./shared/bootstrap"

CV::Zhbook.query.each do |zhbook|
  zhbook.zseed = CV::NvSeed.map_id(zhbook.sname)
  zhbook.fix_id!
  zhbook.save!
end

FileUtils.rm_rf("var/chtexts/local")
FileUtils.rm_rf("var/chtexts/chivi")
FileUtils.mkdir_p("var/chtexts/chivi")
