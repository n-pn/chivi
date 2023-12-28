INP = "/2tb/var.chivi/zroot/wntext"
OUT = "/mnt/serve/chivi.all/saved"

snames = ARGV.reject(&.starts_with?('-'))

snames.each do |sname|
  out_dir = "#{OUT}/#{sname}"

  inp_path = "#{INP}/#{sname}"
  sn_ids = Dir.children(inp_path)
  next if sn_ids.empty?

  Dir.mkdir_p(out_dir)
  sn_ids.each do |sn_id|
    zip_path = "#{out_dir}/#{sn_id}.zip"
    puts "zipping: #{inp_path}/#{sn_id} to #{zip_path}"

    `zip -rjyoqm '#{zip_path}' '#{inp_path}/#{sn_id}'`
  end
end
