require "colorize"

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

INP = "/media/nipin/Vault/Asset/chivi_db/chaps/.html"
TMP = "/www/chivi/cwd"
SET = "/www/chivi/txt/saved"

def restore(inp_sname : String)
  out_sname = MAP_SNAME[inp_sname]
  log_file = "#{TMP}/#{out_sname}-html.log"

  recovered = begin
    File.read_lines(log_file).to_set
  rescue
    Set(String).new
  end

  checked = 0
  restore = 0

  sname_dir = "#{INP}/#{inp_sname}"
  entries = Dir.children(sname_dir).shuffle!

  entries.each_with_index(1) do |wn_id, index|
    next if wn_id.in?(recovered) || wn_id.includes?('.')
    entry_dir = "#{sname_dir}/#{wn_id}"

    htm_files = Dir.children(entry_dir).select(&.ends_with?(".html.gz"))
    next if htm_files.empty?

    tmp_dir = "#{TMP}/#{out_sname}/#{wn_id}"
    Dir.mkdir_p(tmp_dir)

    existed = begin
      File.read("#{SET}/#{out_sname}/#{wn_id}.txt").split(' ').to_set
    rescue
      Set(String).new
    end

    htm_files.each do |htm_file|
      checked += 1

      sc_id = htm_file.split('.', 2).first
      next if existed.includes?(sc_id)

      tmp_path = "#{tmp_dir}/#{htm_file}"
      next if File.exists?(tmp_path)

      puts "<#{index} (#{restore}/#{checked})>: #{out_sname}/#{wn_id}/#{htm_file} found!".colorize.yellow
      File.copy("#{entry_dir}/#{htm_file}", tmp_path)

      restore += 1
    rescue err
      puts err
    end

    File.open(log_file, "a", &.puts(wn_id))
    sleep 300.milliseconds
  rescue err
    puts err
  end

  puts "restored: #{restore} chapters"
end

# restore("bxwxorg")
restore("jx_la")
