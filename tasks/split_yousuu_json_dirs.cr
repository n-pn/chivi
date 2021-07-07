require "file_utils"
DIR = "_db/yousuu"

def move_infos
  files = Dir.glob("#{DIR}/.cache/infos/*.json")

  files.each do |file|
    snvid = File.basename(file, ".json")

    group = (snvid.to_i // 1000).to_s.rjust(3, '0')
    out_dir = "#{DIR}/infos/#{group}"

    FileUtils.mkdir_p(out_dir)
    FileUtils.mv(file, "#{out_dir}/#{snvid}.json")
  end
end

def move_crits
  files = Dir.glob("#{DIR}/.cache/crits/*.json")

  files.each do |file|
    fname = File.basename(file, ".json")
    snvid, page = fname.split("-")

    group = (snvid.to_i // 1000).to_s.rjust(3, '0')
    out_dir = "#{DIR}/crits/#{group}"

    FileUtils.mkdir_p(out_dir)
    FileUtils.mv(file, "#{out_dir}/#{snvid}-#{page}.json")
  end
end

move_infos
move_crits
