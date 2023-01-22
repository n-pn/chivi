require "../member/vi_user"

time_zone = Time::Location.load("Asia/Ho_Chi_Minh")

CV::Viuser.query.where("privi > 0 and privi < 4").each do |viuser|
  _privi = viuser.privi
  _until = Time.unix(viuser.until).in(time_zone)
  puts "checking #{viuser.uname.colorize.yellow}, privi: #{_privi.colorize.yellow},\tuntil: #{_until.colorize.yellow}"

  viuser.downgrade_privi!
  next if viuser.privi == _privi
  puts "#{viuser.uname} downgraded from #{_privi} to #{viuser.privi}".colorize.cyan
  viuser.save!
end
