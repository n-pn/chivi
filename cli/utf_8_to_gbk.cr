require "colorize"

def convert_dir(dir : String, delete : Bool = false)
  files = Dir.glob("#{dir}/**/*.txt")

  workers = Channel({String, Int32}).new(files.size)

  threads = 6
  results = Channel(Nil).new(threads)

  threads.times do
    spawn do
      loop do
        txt_file, idx = workers.receive
        gbk_file = txt_file.sub(".txt", ".gbk")

        File.write(gbk_file, File.read(txt_file).encode("GB18030"), encoding: "GB18030")
        File.delete(txt_file) if delete
        puts " - <#{idx}/#{files.size}> [#{gbk_file}]"
      rescue err
        puts " #{txt_file}, #{err.message} ".colorize.red
      ensure
        results.send(nil)
      end
    end
  end

  files.each_with_index(1) { |file, idx| workers.send({file, idx}) }
  files.size.times { results.receive }
end

delete = ARGV.includes?("--delete")

ARGV.each do |argv|
  convert_dir(argv, delete: delete) unless argv.starts_with?('-')
end
