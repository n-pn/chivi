require "file_utils"

INP = "_db/ch_infos/origs"
OUT = "_db/chseed"

seeds = Dir.children(OUT)

seeds.each do |sname|
  files = Dir.glob("#{INP}/#{sname}/*.tsv")

  files.each do |file|
    snvid = File.basename(file, ".tsv")
    out_dir = "#{OUT}/#{sname}/#{snvid}"

    FileUtils.mkdir_p(out_dir)
    FileUtils.mv(file, "#{out_dir}/_id.tsv")
  end
end
