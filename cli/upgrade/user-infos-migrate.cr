require "../../src/filedb/*"
require "../../src/_utils/text_util"
require "../../src/kernel/user_info"

files = Dir.glob("var/appcv/members/*.json")

OUT = "_db/prime/member/infos"
FileUtils.rm_rf(OUT)

# TODO:
# - sort users by creation time
# - fake join dates

umail_map = ValueMap.new("#{OUT}/umail.tsv")
uname_map = ValueMap.new("#{OUT}/uname.tsv")

dname_map = ValueMap.new("#{OUT}/dname.tsv")
email_map = ValueMap.new("#{OUT}/email.tsv")

cpass_map = ValueMap.new("#{OUT}/cpass.tsv")
power_map = ValueMap.new("#{OUT}/power.tsv")

uhash_map = ValueMap.new("#{OUT}/uhash.tsv")

files.each do |file|
  user = UserInfo.read!(file)

  umail_map.upsert!(user.email.downcase, user.uname, mtime: 0)
  uname_map.upsert!(user.uname.downcase, user.uname, mtime: 0)

  dname_map.upsert!(user.uname, user.uname.downcase, mtime: 0)
  email_map.upsert!(user.uname, user.email, mtime: 0)

  cpass_map.upsert!(user.uname, user.cpass, mtime: 0)
  power_map.upsert!(user.uname, user.power.to_s, mtime: 0)

  uhash_map.upsert!(user.uslug, user.uname, mtime: 0)
end

uname_map.save!
umail_map.save!

dname_map.save!
email_map.save!

cpass_map.save!
power_map.save!

uhash_map.save!
