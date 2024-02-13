require "colorize"
require "compress/zip"
require "../../src/rdapp/data/czdata"

INP = "/www/var.chivi/zroot/rawtxt"

MAPPING_SQL = <<-SQL
select s_cid, ch_no from czdata where s_cid > 0
SQL

snames = ARGV.reject(&.starts_with?('-'))
snames = ["!69shuba.com"] if snames.empty?

snames.each do |sname|
  out_dir = "/2tb/zroot/recover/#{sname}"
  Dir.mkdir_p(out_dir)

  no_remote = sname.in? "~avail", "!zxcs.me"

  zip_paths = Dir.glob("#{INP}/#{sname}/*.zip")
  zip_paths.each do |zip_path|
    sn_id = File.basename(zip_path, ".zip")
    next if sn_id == "bad-text.log"

    txt_dir = "#{out_dir}/#{sn_id}"
    Dir.mkdir_p(txt_dir)

    knowns = RD::Czdata.db(sname, sn_id).open_ro do |db|
      db.query_all("select s_cid from czdata where s_cid > 0", as: Int32).to_set
    end

    missing = [] of Int32

    Compress::Zip::File.open(zip_path) do |zip|
      zip.entries.each do |entry|
        case entry.filename
        when .ends_with?(".gbk")
          s_cid = File.basename(entry.filename, ".gbk").to_i
          encoding = "GB18030"
        when .ends_with?(".txt")
          s_cid = File.basename(entry.filename, ".txt").to_i
        else
          next
        end

        next if knowns.includes?(s_cid)
        missing << s_cid

        ztext = entry.open do |io|
          io.set_encoding(encoding, invalid: :skip) if encoding
          io.gets_to_end
        end

        File.write("#{txt_dir}/#{s_cid}.txt", ztext)
      end
    end

    next if missing.empty?

    puts "#{zip_path}: #{missing.size} missing"
    File.write("#{out_dir}/#{sn_id}-missing.log", missing.join('\t'))
  end
end
