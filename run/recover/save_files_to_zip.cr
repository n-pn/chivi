require "colorize"

DIR = "/2tb/zroot/ztext"

Dir.each_child(DIR) do |sname|
  Dir.glob("#{DIR}/#{sname}/*/").each do |tmp_path|
    tmp_path = tmp_path.rchop('/')
    zip_path = tmp_path + ".zip"
    puts "#{tmp_path} => #{zip_path}"
    `zip -rjyomq '#{zip_path}' '#{tmp_path}'`
  end
end
