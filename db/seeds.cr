require "../config/application"

# require "./seeds/add_default_users"
# require "./seeds/add_pseudo_nvinfo"
# require "./seeds/fix_forum_metadata"
# require "./seeds/fix_cvpost_lasttp"

def create_author(zname : String, id : Int64)
  CV::Author.new({
    id:    id,
    zname: zname,
    vname: zname,
    vslug: CV::BookUtil.make_slug(zname.downcase),
  }).save!
rescue err
  puts err
end

def create_nvinfo(zname : String, id : Int64)
  slug = CV::BookUtil.scrub_vname(zname, "-")

  CV::Nvinfo.new({
    id:        id,
    author_id: 0,
    zname:     zname,
    hname:     zname,
    vname:     zname,
    bhash:     slug,
    bslug:     slug,
    vslug:     "-#{slug}-",
    hslug:     "-#{slug}-",
    shield:    2,
  }).save!
rescue err
  puts err
end

create_author("System", 0)
create_nvinfo("Đại sảnh", -1)
create_nvinfo("Hướng dẫn", -2)
create_nvinfo("Thông báo", -3)
