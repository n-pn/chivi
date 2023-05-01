require "colorize"
require "compress/zip"

MAP_SNAME = {
  "biqugee":  "!biqugee.com",
  "bxwxorg":  "!bxwxorg.com",
  "rengshu":  "!rengshu.com",
  "shubaow":  "!shubaow.net",
  "duokan8":  "!duokan8.com",
  "paoshu8":  "!paoshu8.com",
  "miscs":    "!chivi.app",
  "xbiquge":  "!xbiquge.so",
  "hetushu":  "!hetushu.com",
  "69shu":    "!69shu.com",
  "sdyfcm":   "!nofff.com",
  "nofff":    "!nofff.com",
  "5200":     "!5200.tv",
  "zxcs_me":  "!zxcs.me",
  "jx_la":    "!jx.la",
  "ptwxz":    "!ptwxz.com",
  "uukanshu": "!uukanshu.com",
  "uuks":     "!uuks.org",
  "bxwxio":   "!bxwx.io",
  "133txt":   "!133txt.com",
  "biqugse":  "!biqugse.com",
  "bqxs520":  "!bqxs520.com",
  "yannuozw": "!yannuozw.com",
  "kanshu8":  "!kanshu8.net",
  "biqu5200": "!biqu5200.net",
  "b5200":    "!b5200.org",
}

INP = "/media/nipin/Vault/Asset/chivi_db/chtexts"
OUT = "/mnt/serve/chivi.all/var/texts/rgbks"

def restore(inp_sname : String)
  out_sname = MAP_SNAME[inp_sname]

  sname_dir = File.join(INP, inp_sname)
  wn_ids = Dir.children(sname_dir).reject!(&.includes?('.'))

  wn_ids.each_with_index(1) do |wn_id, index|
    sleep 5.seconds if index % 1000 == 0

    inp_dir = File.join(sname_dir, wn_id)
    zip_files = Dir.glob(File.join(inp_dir, "*.zip"))

    tmp_dir = File.join("/www/chivi/cwd/#{out_sname}/#{wn_id}")
    Dir.mkdir_p(tmp_dir)

    out_dir = File.join(OUT, out_sname, wn_id)

    zip_files.each do |zip_path|
      puts "#{zip_path}"
      restore_from_zip(zip_path, out_dir, tmp_dir)
    end
  end
end

def restore_from_zip(zip_path : String, out_dir : String, tmp_dir)
  existed =
    if File.directory?(out_dir)
      Dir.children(out_dir).map { |file| File.basename(file, ".gbk") }.to_set
    else
      Set(String).new
    end

  missing = Set(String).new

  Compress::Zip::File.open(zip_path) do |zip|
    zip.entries.each do |entry|
      sc_id, cpart = File.basename(entry.filename, ".txt").split('-')
      next if existed.includes?(sc_id)
      missing << sc_id
    end

    if missing.size > 0
      tmp_path = File.join(tmp_dir, File.basename(zip_path))
      File.copy(zip_path, tmp_path)
      puts "copy zip_file to tmp path!".colorize.yellow
    else
      puts "all restored!".colorize.green
    end

    File.rename(zip_path, zip_path + ".done")
  end
end

# def restore_file(zip : Compress::Zip::File, out_dir : String, sc_id : String, parts : Array(String))
#   out_path = File.join(out_dir, "#{sc_id}.gbk")

#   ztext = zip["#{sc_id}-0.txt"].open(&.gets_to_end)
#   ztext = ztext.sub('\n', "\n\n") # seperate title with body

#   parts.sort!(&.to_i).shift

#   parts.each do |cpart|
#     ptext = zip["#{sc_id}-#{cpart}.txt"].open(&.gets_to_end)
#     ztext += ptext.sub(/^.+\n/, "\n\n")
#   end

#   puts data
#   gets

#   write_file(out_path, ztext)
# end

# def write_file(path : String, data : String)
#   File.write(path, data.encode("GB18030"), encoding: "GB18030")
# end

restore("bxwxorg")
