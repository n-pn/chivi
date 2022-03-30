users = [
  CV::Cvuser.new({
    id:     0,
    uname:  "Khách",
    email:  "guest@chivi.app",
    cpass:  "xxxxxxxxx",
    privi:  -1,
    wtheme: "light",
  }),
  CV::Cvuser.new({
    id:     -1,
    uname:  "Admin",
    email:  "admin@chivi.app",
    cpass:  "xxxxxxxxx",
    privi:  4,
    wtheme: "warm",
  }),
  CV::Cvuser.new({
    id:     -2,
    uname:  "Hệ thống",
    email:  "system@chivi.app",
    cpass:  "xxxxxxxxx",
    privi:  5,
    wtheme: "light",
  }),
  CV::Cvuser.new({
    id:     -3,
    uname:  "Staff",
    email:  "staff@chivi.app",
    cpass:  "xxxxxxxxx",
    privi:  3,
    wtheme: "dark",
  }),
]

users.each do |user|
  user.save
rescue err
  puts err
end
