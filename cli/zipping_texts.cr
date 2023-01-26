require "colorize"

INP = "var/chaps/texts-txt"
OUT = "/mnt/devel/Chivi/texts"

MAP_SNAME = {
  "zxcs_me"  => "!zxcs.me",
  "!zxcs_me" => "!zxcs.me",
  "jx_la"    => "!jx.la",
  "!jx_la"   => "!jx.la",
}

def map_sname(sname : String)
  MAP_SNAME[sname]? || begin
    sname[0].in?('+', '!', '_', '@') ? sname : "!" + sname
  end
end

def zipping_dir(inp_sname : String)
  out_sname = map_sname(inp_sname)
  out_dir = "#{OUT}/#{out_sname}"

  Dir.mkdir_p(out_dir)
  puts out_dir.colorize.yellow

  inputs = Dir.children("#{INP}/#{inp_sname}").compact_map do |dirname|
    zip_path = "#{OUT}/#{out_sname}/#{dirname}.zip"
    next if File.file?(zip_path)

    inp_path = "#{INP}/#{inp_sname}/#{dirname}"
    {zip_path, inp_path}
  end

  workers = Channel({String, String, Int32}).new(inputs.size)

  threads = 6
  results = Channel(Nil).new(threads)

  threads.times do
    spawn do
      loop do
        zip_path, inp_path, idx = workers.receive
        `zip -jqr '#{zip_path}' '#{inp_path}'`
        puts " - #{idx}/#{inputs.size}: #{zip_path}"
      rescue err
        puts err.inspect_with_backtrace
        puts "#{inp_sname}, #{zip_path}, #{err.message} ".colorize.red
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

snames.each { |sname| zipping_dir(sname) }
