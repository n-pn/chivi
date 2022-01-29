CV::Author.new({
  id:     0,
  zname:  "system",
  vname:  "system",
  vslug:  "",
  weight: -1,
}).save

data = Array(CV::Nvinfo).from_json(File.read("db/seeds/nvinfos.json"))

data.each do |info|
  info.save
rescue err
  puts err
end
