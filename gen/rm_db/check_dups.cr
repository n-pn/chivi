require "colorize"
tsinghua = Dir.children("/2tb/zroot/rm_db/tsinghua").map { |x| x.rchop(".db3") }
ibiquw = Dir.children("/2tb/zroot/rm_db/ibiquw.com").map { |x| x.split("__")[1] }

existed = ibiquw.to_set

tsinghua.each do |title|
  if existed.includes?(title)
    puts title.colorize.light_gray
  else
    puts title.colorize.green
  end
end

puts tsinghua - ibiquw
