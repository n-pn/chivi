require "../shared/bootstrap"

users = CV::Viuser.query.where("privi > 0")

users.each do |user|
  sname = "@" + user.uname
  next if CV::ChSeed.has_sname?(sname)
  sn_id = user.id * 2 + 20
  CV::ChSeed.add_user(sname, sn_id)
end

users_2 = Dir.children("var/chtexts").select(&.starts_with?('@'))
users_2.each do |uname|
  next if CV::ChSeed.has_sname?(uname)

  if user = CV::Viuser.find({uname: uname[1..]})
    sn_id = user.id * 2 + 20
    CV::ChSeed.add_user(uname, sn_id)
  else
    puts "user #{uname} does not exists!"
  end
end
