require "./shared/bootstrap"
DIR = "var/vpdicts/v1/novel"

input = Dir.children(DIR).map { |x| File.basename(x, File.extname(x)) }

input.uniq!.each do |dname|
  next if CV::Nvdict.find({dname: dname})
  CV::Nvdict.init!(dname).save!
rescue err
  puts err
end
