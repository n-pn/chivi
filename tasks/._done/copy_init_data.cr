require "file_utils"

INP_DIR = "_db/zhbook"
OUT_DIR = "var/nvinfos/autos"

def copy_file(inp_file, out_dir, type = :covers)
  FileUtils.mkdir_p(out_dir)

  infos = File.read_lines(inp_file).reject(&.empty?)

  chunks = infos.group_by do |line|
    snvid = line.split('\t', 2)[0]
    snvid.rjust(4, '0')[0..-4]
  end

  puts "size: #{infos.size}, page: #{chunks.size}"

  chunks.each do |group, lines|
    out_file = File.join(out_dir, "#{type}-#{group}.tsv")
    # TODO: transform data by type
    File.write(out_file, lines.join("\n"))
  end
end

Dir.children(INP_DIR).each do |sname|
  puts sname
  next if sname == "chivi" || sname == "zhwenpg"

  inp_dir = File.join(INP_DIR, sname)
  # out_dir = File.join(OUT_DIR, sname)
  next unless File.directory?(inp_dir)

  # copy_file("#{inp_dir}/_index.tsv", "#{out_dir}/_index", :_index)
  # copy_file("#{inp_dir}/genres.tsv", "#{out_dir}/genres", :genres)
  # copy_file("#{inp_dir}/status.tsv", "#{out_dir}/status", :status)
  # copy_file("#{inp_dir}/mftime.tsv", "#{out_dir}/utimes", :utimes)
  # copy_file("#{inp_dir}/bcover.tsv", "#{out_dir}/covers", :covers)
  # FileUtils.cp_r("#{inp_dir}/intros", "#{out_dir}/intros")
end
