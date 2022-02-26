require "../shared/bootstrap"

def fix_zseed(sname : String)
  CV::Zhbook.query.where(sname: sname).each do |zhbook|
    zhbook.zseed = CV::NvSeed.map_id(zhbook.sname)
    zhbook.fix_id!
    zhbook.save!
  end
end

# fix_zseed("sdyfcm")
# fix_zseed("jx_la")
# fix_zseed("zhwenpg")

# CV::NvSeed::MAP_ID.each_key { |sname| fix_zseed(sname) }

# FileUtils.rm_rf("var/chtexts/chivi")
# FileUtils.mkdir_p("var/chtexts/chivi")

CV::Nvinfo.query.each do |nvinfo|
  zhbooks = nvinfo.zhbooks.to_a.reject(&.zseed.== 0)
  nvinfo.update!({zseed_ids: zhbooks.map(&.zseed).sort})
end
