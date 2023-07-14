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
TMP = "/www/chivi/cwd"
SET = "/www/chivi/txt/saved"

def restore(inp_sname : String)
  out_sname = MAP_SNAME[inp_sname]
  log_file = "#{TMP}/#{out_sname}.log"

  recovered = begin
    File.read_lines(log_file).to_set
  rescue
    Set(String).new
  end

  checked = 0

  sname_dir = "#{INP}/#{inp_sname}"
  entries = Dir.children(sname_dir).shuffle!

  entries.each_with_index(1) do |wn_id, index|
    next if wn_id.in?(recovered) || wn_id.includes?('.')
    entry_dir = "#{sname_dir}/#{wn_id}"

    zip_files = Dir.children(entry_dir).select(&.ends_with?(".zip"))
    next if zip_files.empty?

    tmp_dir = "#{TMP}/#{out_sname}/#{wn_id}"
    Dir.mkdir_p(tmp_dir)

    existed = begin
      File.read("#{SET}/#{out_sname}/#{wn_id}.txt").split(' ').to_set
    rescue
      Set(String).new
    end

    zip_files.each do |zip_file|
      tmp_path = "#{tmp_dir}/#{zip_file}"
      next if File.exists?(tmp_path)

      zip_path = "#{entry_dir}/#{zip_file}"
      puts "<#{index} (#{checked})>: #{zip_path}".colorize.blue

      restore_from_zip(zip_path, tmp_path, existed)
    rescue err
      puts err
    end

    File.open(log_file, "a", &.puts(wn_id))

    checked += zip_files.size
    break if checked > 10000
  rescue err
    puts err
  end
end

def restore_from_zip(zip_path : String, tmp_path : String, existed : Set(String)) : Int32
  missing = Set(String).new

  Compress::Zip::File.open(zip_path) do |zip|
    zip.entries.each do |entry|
      sc_id, _ = entry.filename.split('-', 2)
      missing << sc_id unless existed.includes?(sc_id)
    end

    if missing.size > 0
      File.copy(zip_path, tmp_path)
      # TODO: unzip file to out_path

      puts "copy zip_file to tmp path!".colorize.yellow
    else
      puts "all restored!".colorize.green
    end

    # File.rename(zip_path, zip_path + ".done") rescue puts "error renaming file!".colorize.red
  end

  missing.size > 0 ? 1 : 0 # add to counter if new text entries found
end

def extract_zip(zip_path : String, out_dir : String, skip_existing = true)
  entries = {} of String => Array(String)

  Compress::Zip::File.open(zip_path) do |zip|
    zip.entries.each do |entry|
      sc_id, cpart = entry.filename.sub(".txt", "").split('-', 2)
      parts = entries[sc_id] ||= [] of String
      parts << cpart
    end

    entries.each do |sc_id, parts|
      out_path = File.join(out_dir, "#{sc_id}.gbk")
      next if skip_existing && File.file?(out_path)
      puts "saving file #{out_path}".colorize.yellow

      ztext = zip["#{sc_id}-0.txt"].open(&.gets_to_end)
      ztext = ztext.sub('\n', "\n\n") # seperate title with body
      parts.sort!(&.to_i).shift

      parts.each do |cpart|
        ptext = zip["#{sc_id}-#{cpart}.txt"].open(&.gets_to_end)
        ztext += ptext.sub(/^.+\n/, "\n\n")
      end

      begin
        File.write(out_path, ztext.encode("GB18030"), encoding: "GB18030")
      rescue ArgumentError
        File.write(out_path.sub(".gbk", ".txt"), ztext)
      end
    end
  end
end

def extract_dir(inp_sname : String)
  out_sname = MAP_SNAME[inp_sname]
  zip_paths = Dir.glob("#{TMP}/#{out_sname}/**/*.zip")

  zip_paths.each do |zip_path|
    out_dir = File.dirname(zip_path).sub(TMP, OUT)
    puts "restoring #{zip_path} to #{out_dir}".colorize.cyan
    extract_zip(zip_path, out_dir)
  rescue err
    puts err
  end
end

# restore("bxwxorg")
restore("5200")
# extract_dir("bxwxorg")
