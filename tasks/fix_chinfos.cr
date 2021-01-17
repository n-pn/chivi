require "colorize"

DIR = "_db/chdata/chinfos"
Dir.glob("#{DIR}/*/").each do |dir|
  puts dir

  Dir.glob("#{dir}*/index.tsv").each do |file|
    puts file
    out_file = file.sub("index.tsv", "_seed.tsv")
    out_data = [] of String

    File.each_line(file) do |line|
      next if line.strip.empty?
      cols = line.strip.split('\t')

      item = [cols[0], cols[2]]

      if label = cols[3]?
        item << label
      end

      out_data << item.join('\t')
    rescue
      puts line.colorize.red
    end

    File.write(out_file, out_data.join('\n'))
  end
end
