require "file_utils"

DIR = "_db/vpinit/bd_lac"

Dir.children(DIR).each do |dir|
  next if dir == ".old"
  sum_folder(File.join(DIR, dir))
end

def sum_folder(dir : String)
  inps = Dir.glob("#{dir}/*.tsv")
  puts "- #{dir} has #{inps.size} files"

  return FileUtils.rm_rf(dir) if inps.empty?

  inps.each do |inp_file|
    out_file = inp_file.sub(/.tsv$/, ".sum")
    next unless outdated?(out_file, File.info(inp_file).modification_time)

    output = sum_file(inp_file)
    write_output(out_file, output)
  end
end

def outdated?(file : String, time : Time)
  return true unless info = File.info?(file)
  info.modification_time < time
end

# IGNORE = Set(String).new

alias CountTag = Hash(String, Int32)
alias CountStr = Hash(String, CountTag)

def sum_file(inp_file : String)
  output = CountStr.new do |h, k|
    h[k] = CountTag.new { |h2, k2| h2[k2] = 0 }
  end

  File.each_line(inp_file) do |line|
    line.split('\t') do |word|
      frags = word.split(' ', 2)
      next if frags.size < 2

      hanzi, count = frags
      output[hanzi][count] &+= 1
    end
  end

  output
end

def write_output(file : String, data : CountStr)
  File.open(file, "w") do |io|
    data.each do |term, counts|
      io << term
      counts.each do |tag, count|
        io << '\t' << tag << ' ' << count
      end
      io << '\n'
    end
  end
end
