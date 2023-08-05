require "colorize"

INP = "var/ztext"
OUT = "var/zroot"

def gen_out_dir(sname : String)
  case sname[0]
  when '!' then "#{OUT}/remote/#{sname}"
  when '@' then "#{OUT}/member/#{sname}"
  else          "#{OUT}/system/#{sname}"
  end
end

def zip_seed_dir(sname : String, threads : Int32 = WORKERS, upload = false)
  inp_dir = "#{INP}/#{sname}"
  out_dir = gen_out_dir(sname)
  Dir.mkdir_p(out_dir)

  puts out_dir.colorize.yellow

  inputs = Dir.children(inp_dir).map do |b_id|
    {"#{out_dir}/#{b_id}.zip", "#{inp_dir}/#{b_id}"}
  end

  workers = Channel({String, String, Int32}).new(inputs.size)
  results = Channel({String, Int32}).new(threads)

  threads.times do
    spawn do
      loop do
        zip_path, inp_path, idx = workers.receive
        `zip -FSrjyoq '#{zip_path}' '#{inp_path}'`
        results.send({zip_path, idx})
      end
    end
  end

  inputs.each_with_index(1) { |(zip_path, txt_path), idx| workers.send({zip_path, txt_path, idx}) }
  inputs.size.times do
    zip_path, idx = results.receive
    puts " - #{idx}/#{inputs.size}: #{zip_path}"
  end

  return unless upload
  `rclone sync '#{OUT}/#{sname}' 'b2:cvtxts/#{sname}' -v --auto-confirm`
end

threads = ENV["WORKERS"]?.try(&.to_i?) || 6

upload = ARGV.includes?("--upload")
snames = ARGV.reject(&.starts_with?('-'))
snames = Dir.children(INP) if snames.empty?

snames.select!(&.starts_with?('@')) if ARGV.includes?("--users")
snames.select!(&.starts_with?('!')) if ARGV.includes?("--globs")

snames.each { |sname| zip_seed_dir(sname, threads: threads, upload: upload) }
