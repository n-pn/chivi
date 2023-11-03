require "../../src/rdapp/data/czdata"
require "../../src/rdapp/data/chinfo"

STEM_DIR = "/2tb/var.chivi/stems"
TEXT_DIR = "/2tb/var.chivi/texts"

def read_cbody(spath : String, cksum : String, psize : Int32)
  return "" if cksum.empty?

  String.build do |io|
    1.upto(psize) do |p_idx|
      fpath = "#{TEXT_DIR}/#{spath}-#{cksum}-#{p_idx}.raw.txt"
      lines = File.read_lines(fpath, chomp: true)
      lines.shift if p_idx > 1
      lines.each { |line| io << line << '\n' }
    end
  end
rescue
  ""
end

def import(sname : String, sn_id : String, uname = sname.sub("rm", ""))
  cinfos = RD::Chinfo.db("#{sname}/#{sn_id}").open_ro do |db|
    db.query_all "select * from chinfos where ch_no > 0 order by ch_no asc", as: RD::Chinfo
  end

  zdatas = cinfos.map do |cinfo|
    RD::Czdata.new(
      ch_no: cinfo.ch_no,
      cbody: read_cbody(cinfo.spath, cinfo.cksum, cinfo.psize),
      title: cinfo.ztitle,
      chdiv: cinfo.zchdiv,
      uname: uname,
      zorig: cinfo.spath,
      mtime: cinfo.mtime
    )
  end

  RD::Czdata.db("#{sname}/#{sn_id}").open_tx do |db|
    zdatas.each(&.upsert!(db: db))
  end

  puts "#{sname}/#{sn_id}: #{zdatas.size} entries saved!"
end

snames = ARGV.select!(&.starts_with?('!'))
snames = ["!69shuba.com"] if snames.empty?

snames.each do |sname|
  cinfos = Dir.glob("#{STEM_DIR}/rm#{sname}/*-cinfo.db3")
  # exists = Dir.glob("#{STEM_DIR}/rm#{sname}/*-zdata.db3").to_set

  cinfos.each do |fpath|
    # next if exists.includes?(fpath.sub("cinfo", "zdata"))
    sn_id = File.basename(fpath, "-cinfo.db3")
    import("rm#{sname}", sn_id)
  rescue ex
    puts [fpath, ex]
  end
end
