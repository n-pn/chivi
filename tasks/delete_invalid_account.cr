require "../src/appcv/filedb/vi_user"

CV::ViUser.emails.each do |uname, vals|
  email = vals.first

  next unless CV::ViUser.valid_pass?(uname, email)

  puts [uname, email]
  CV::ViUser._index.delete!(uname)
  CV::ViUser.emails.delete!(uname)
end
