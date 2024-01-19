# INP = "/2tb/var.chivi/zroot/wntext"
INP = "/mnt/serve/chivi.all/users"
OUT = "/media/nipin/Chivi/users"

snames = Dir.children(INP)

snames.each do |sname|
  out_dir = "#{OUT}/#{sname}"
  Dir.mkdir_p(out_dir)

  inp_path = "#{INP}/#{sname}"
  sn_ids = Dir.children(inp_path)
  next if sn_ids.empty?

  sn_ids.each do |sn_id|
    zip_path = "#{out_dir}/#{sn_id}.zip"
    puts "zipping: #{inp_path}/#{sn_id} to #{zip_path}"

    `zip -rjyoqm '#{zip_path}' '#{inp_path}/#{sn_id}'`
  end
end
