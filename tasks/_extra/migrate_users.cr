require "../../src/_oldcv/kernel/userdb"
require "../../src/filedb/viuser"

Oldcv::UserDB.emails.data.each_value do |uslug|
  next unless info = Oldcv::UserInfo.get!(uslug)
  puts info.to_pretty_json

  if uname = CV::Viuser.set_uname(info.uname)
    CV::Viuser.set_email(uname, info.email)
    CV::Viuser.passwd.add(uname, info.cpass)
    CV::Viuser.set_power(uname, info.power)
  end
rescue err
  puts err
end

CV::Viuser.save!(mode: :full)
