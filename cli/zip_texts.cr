require "colorize"

INP = ENV["INP"]? || "var/texts/rgbks"
OUT = ENV["OUT"]? || "/mnt/devel/Chivi/texts"

WORKERS = ENV["WORKERS"]?.try(&.to_i?) || 6

def zip_seed_dir(sname : String, threads : Int32 = WORKERS)
  out_dir = "#{OUT}/#{sname}"

  Dir.mkdir_p(out_dir)
  puts out_dir.colorize.yellow

  inputs = Dir.children("#{INP}/#{sname}").compact_map do |dirname|
    zip_path = "#{OUT}/#{sname}/#{dirname}.zip"
    next if File.file?(zip_path)

    inp_path = "#{INP}/#{sname}/#{dirname}"
    {zip_path, inp_path}
  end

  workers = Channel({String, String, Int32}).new(inputs.size)

  results = Channel(Nil).new(threads)

  threads.times do
    spawn do
      loop do
        zip_path, inp_path, idx = workers.receive
        `zip -jqr '#{zip_path}' '#{inp_path}'`
        puts " - #{idx}/#{inputs.size}: #{zip_path}"
      rescue err
        puts err.inspect_with_backtrace
        puts "#{sname}, #{zip_path}, #{err.message} ".colorize.red
      ensure
        results.send(nil)
      end
    end
  end

  inputs.each_with_index(1) do |(zip_path, inp_path), idx|
    workers.send({zip_path, inp_path, idx})
  end

  inputs.size.times { results.receive }
end

snames = ARGV.reject(&.starts_with?('-'))
snames = Dir.children(INP) if snames.empty?

snames.each { |sname| zip_seed_dir(sname) }
