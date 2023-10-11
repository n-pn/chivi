require "pg"
require "sqlite3"
ENV["CV_ENV"] = "production"
require "../../src/cv_env"

TXT_DIR = "var/texts"
wn_ids = Dir.children(TXT_DIR).select!(&.to_i?)

wn_ids.each do |wn_id|
  inp_dir = "#{TXT_DIR}/#{wn_id}"
  out_dir = "var/texts/wn~avail/#{wn_id}"
  Dir.mkdir_p(out_dir)

  inp_files = Dir.children(inp_dir)
  out_files = Dir.children(out_dir).to_set

  puts "#{wn_id}: #{inp_files.size}"
  inp_files.reject!(&.in?(out_files))

  inp_files.each do |inp_name|
    inp_file = "#{inp_dir}/#{inp_name}"
    out_file = "#{out_dir}/#{inp_name}"
    File.copy(inp_file, out_file)
  rescue ex
    puts ex
  end

  `rm -rf #{inp_dir}`
  puts " #{inp_files.size} moved!"
end
