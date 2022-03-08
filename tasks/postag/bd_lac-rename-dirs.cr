require "colorize"
require "file_utils"
require "../shared/bootstrap"

# def copy!(nvseeds : Array(Zhbook))
#   nvseeds.sort_by!(&.zseed).each { |x| copy_old!(x) }
# end

# def copy_old!(nvseed : Zhbook)
#   return if nvseed.zseed == 0

#   old_dir = File.join(OUT_DIR, ".old", nvseed.sname, nvseed.snvid)
#   return unless File.exists?(old_dir)

#   inp_dir = File.join(INP_DIR, nvseed.sname, nvseed.snvid)
#   indexes = {} of String => Int32

#   Dir.glob("#{inp_dir}/*.tsv").each do |file|
#     ChList.new(file).data.each_value do |info|
#       indexes[info.schid] = info.chidx
#     end
#   end

#   Dir.glob("#{old_dir}/*-0.tsv").each do |old_tsv|
#     next unless chidx = indexes[get_chidx(old_tsv)]?

#     out_tsv = File.join(@out_path, "#{chidx}-0.tsv")
#     next if File.exists?(out_tsv)

#     FileUtils.mv(old_tsv, out_tsv)
#     puts "- inherit old file #{old_tsv}".colorize.green
#   end

#   FileUtils.rm_rf(old_dir)
# end

DIR = "_db/vpinit/bd_lac"

dirs = Dir.children(DIR)

dirs.each_with_index(1) do |inp_name, i|
  unless binfo = find(inp_name)
    puts "#{inp_name} not found!".colorize.red
    if gets == "delete"
      FileUtils.rm_rf(File.join(DIR, inp_name))
    end

    next
  end

  out_name = binfo.hslug[1..] + binfo.bhash

  next if inp_name == out_name
  puts "[#{i}/#{dirs.size}] invalid name: #{inp_name}".colorize.cyan

  inp_dir = File.join(DIR, inp_name)
  out_dir = File.join(DIR, out_name)

  if File.exists?(out_dir)
    migrate(inp_dir, out_dir)
  else
    FileUtils.mv(inp_dir, out_dir)
  end
end

def find(dir : String)
  bhash = dir.split("-").last
  CV::Nvinfo.find({bhash: bhash}).try { |x| return x }

  books = CV::Nvinfo.query.where("bhash LIKE '#{bhash}%'").to_a
  raise "Duplicate name!" if books.size != 1

  books.first?
end

def migrate(inp_dir, out_dir)
  FileUtils.mkdir_p(out_dir)

  Dir.children(inp_dir).each do |file|
    inp_file = File.join(inp_dir, file)
    out_file = File.join(out_dir, file)

    if File.exists?(out_file)
      File.delete(inp_file)
    else
      FileUtils.mv(inp_file, out_file)
    end
  end

  FileUtils.rmdir(inp_dir)
end
