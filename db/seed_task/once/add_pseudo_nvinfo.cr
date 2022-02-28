CV::Author.new({
  id:     0,
  zname:  "system",
  vname:  "system",
  vslug:  "",
  weight: -1,
}).save

data = Array(JSON::Any).from_json(File.read("db/seed_data/nvinfos.json"))

data.each do |info|
  CV::Nvinfo.new(info).save
rescue err
  puts err
end
