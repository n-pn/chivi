require "zstd"

cctx = Zstd::Compress::Context.new(level: 3)

files = Dir.glob("/mnt/devel/Chivi/corpus-idx/*.tsv")
files.sort_by! { |x| File.basename(x, ".tsv").split('-').first.to_i }

files.each do |file|
  wn_id = File.basename(file, ".tsv")
  out_dir = "/mnt/devel/Chivi/corpus-txt/#{wn_id}"

  Dir.mkdir_p(out_dir)

  File.each_line(file) do |line|
    rows = line.split('\t')
    next if rows.size != 2

    sname = rows[1].split('/', 2).first

    inp_file = "var/texts/rgbks/#{rows[1]}.gbk"
    out_file = "#{out_dir}/#{rows[0]}-[#{sname}].gbk.zst"

    data = File.open(inp_file, &.getb_to_end)
    File.write(out_file, cctx.compress(data))

    puts "#{inp_file} => #{out_file}"
  end
end
