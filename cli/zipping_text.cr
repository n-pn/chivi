require "colorize"

INP = ENV["INP"]? || "var/texts/rgbks"
OUT = ENV["OUT"]? || "var/wn/texts/rzips"

WORKERS = ENV["WORKERS"]?.try(&.to_i?) || 4

def zip_seed_dir(sname : String, threads : Int32 = WORKERS, upload = true)
  out_dir = "#{OUT}/#{sname}"
  puts out_dir.colorize.yellow
  Dir.mkdir_p(out_dir)

  inputs = gen_inputs(sname)

  workers = Channel({String, String, Int32}).new(inputs.size)
  results = Channel(Nil).new(threads)

  threads.times do
    spawn do
      loop do
        zip_path, inp_path, idx = workers.receive
        `zip -FSrjyoq '#{zip_path}' '#{inp_path}'`
        puts " - #{idx}/#{inputs.size}: #{zip_path}"
      rescue err
        puts err.inspect_with_backtrace
        puts "#{sname}, #{zip_path}, #{err.message} ".colorize.red
      ensure
        results.send(nil)
      end
    end
  end

  inputs.each { |input| workers.send(input) }
  inputs.size.times { results.receive }

  return unless upload
  `rclone sync '#{OUT}/#{sname}' 'b2:cvtxts/#{sname}' -v --auto-confirm`
end

def gen_inputs(sname : String)
  index = 0

  Dir.children("#{INP}/#{sname}").compact_map do |dirname|
    zip_path = "#{OUT}/#{sname}/#{dirname}.zip"
    # next if File.file?(zip_path)

    index += 1
    {zip_path, "#{INP}/#{sname}/#{dirname}", index}
  end
end

upload = ARGV.includes?("--upload")
snames = ARGV.reject(&.starts_with?('-'))
snames = Dir.children(INP) if snames.empty?

snames.select!(&.starts_with?('@')) if ARGV.includes?("--member")
snames.select!(&.starts_with?('!')) if ARGV.includes?("--remote")

snames.each { |sname| zip_seed_dir(sname, upload: upload) }
