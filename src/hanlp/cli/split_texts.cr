INP = "/app/texts/zxcs_me"
OUT = "/app/hanlp/data/zxcs_me"

Dir.glob("#{INP}/*.txt").each do |file|
  id = File.basename(file, ".txt")

  out_dir = "#{OUT}/#{id}"
  Dir.mkdir_p(out_dir)

  buffer = [] of String
  wcount = 0
  pcount = 0

  File.each_line(file, chomp: true) do |line|
    next if line.blank?
    line = line.gsub('　', ' ').strip

    buffer << line
    wcount += line.size

    next if wcount < 2000

    File.open("#{out_dir}/#{pcount}.raw", "w") { |f| buffer.join(f, '\n') }
    puts "#{out_dir}/#{pcount}.raw saved!"

    buffer.clear
    wcount = 0
    pcount += 1
  end

  unless buffer.empty?
    File.open("#{out_dir}/#{pcount}.raw", "w") { |file| buffer.join(file, '\n') }
  end
end
