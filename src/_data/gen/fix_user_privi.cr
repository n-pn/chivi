require "../member/vi_user"

CV::Viuser.query.where("privi > 0 and privi < 4").each do |viuser|
  privi = viuser.privi
  viuser.downgrade_privi!
  next if viuser.privi == privi
  puts "#{viuser.uname} downgraded from #{privi} to #{viuser.privi}"
  viuser.save!
end
