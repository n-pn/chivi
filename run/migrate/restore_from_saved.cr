require "compress/zip"
require "../../src/rdapp/data/czdata"

INP = "/mnt/serve/chivi.all/saved"
OUT = "/2tb/zroot/ztext"

snames = Dir.children(INP)

snames.each do |sname|
  children = Dir.children("#{INP}/#{sname}")

  children.each do |child|
    if child.ends_with?(".zip")
      sn_id = File.basename(child, ".zip")
      data = copy_zip("#{INP}/#{sname}/#{child}")
    else
      sn_id = child
      data = copy_dir("#{INP}/#{sname}/#{child}")
    end

    next if data.empty?
    puts "#{sname}/#{sn_id} #{data.size} files copied"

    RD::Czdata.db(sname, sn_id).open_tx do |db|
      data.each(&.upsert!(db: db))
    end
  end
end

def copy_zip(zip_path : String)
  Compress::Zip::File.open(zip_path) do |zip|
    zip.entries.map do |entry|
      s_cid, _cksum, ch_no, _ext = entry.filename.split(/[-.]/)
      RD::Czdata.new(
        ch_no: ch_no.to_i,
        s_cid: s_cid.to_i,
        ztext: entry.open(&.gets_to_end),
        mtime: entry.time.to_unix,
      )
    end
  end
end

def copy_dir(dir_path : String)
  Dir.glob("#{dir_path}/*.txt").map do |fpath|
    s_cid, _cksum, ch_no, _ext = File.basename(fpath).split(/[-.]/)
    RD::Czdata.new(
      ch_no: ch_no.to_i,
      s_cid: s_cid.to_i,
      ztext: File.read(fpath),
      mtime: File.info(fpath).modification_time.to_unix,
    )
  end
end
