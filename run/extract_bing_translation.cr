require "colorize"

DIR = "var/inits/bdtmp/top50/trans"

OUT_DIR = "var/inits/bing_trans"
Dir.mkdir_p(OUT_DIR)

UPPER = [] of Tuple(String, String)
LOWER = [] of Tuple(String, String)

def read_file(file : String)
  label = File.basename(file)

  lines = File.read_lines(file)
  count = lines.size // 2

  count.times do |i|
    words = lines.unsafe_fetch(i * 2).split(',')
    trans = lines.unsafe_fetch(i * 2 + 1).split(',').map(&.strip)

    if words.size != trans.size
      puts "<#{label}/#{i}> error! #{words.size} => #{trans.size}".colorize.red
      # puts words, trans
    else
      puts "<#{label}/#{i}> ok!".colorize.green
    end
  end
end

files = Dir.glob(DIR + "/*.out").sort_by! { |x| File.basename(x, ".out").to_i }

files.first(20).each do |file|
  puts file
  read_file(file)
end
