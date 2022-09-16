require "./shared/bootstrap"

users = CV::Viuser.query.where("privi > 0")

users.each do |user|
  sname = "@" + user.uname
  next if CV::ChSeed.has_sname?(sname)
  sn_id = user.id * 2 + 20
  CV::ChSeed.add_user(sname, sn_id)
end
