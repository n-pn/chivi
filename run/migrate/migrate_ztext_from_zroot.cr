require "colorize"
require "../../src/rdapp/data/czdata"

TXT_DIR = "var/zroot/wntext"
DB3_DIR = "var/stems"

def migrate_seed(old_sname : String, new_sname : String = old_sname)
  txt_dir = File.join(TXT_DIR, old_sname)
  sn_ids = Dir.children(txt_dir)

  sn_ids.each do |sn_id|
    dname = "#{new_sname}/#{sn_id}"
    migrate_book(inp_dir: File.join(txt_dir, sn_id), dname: dname)
  end
end

def migrate_book(inp_dir : String, dname : String)
  cz_db = RD::Czdata.db(dname)

  sname, sn_id = dname.split('/')
  uname = sname.sub("rm", "")


  cdata_hash = cz_db.open_ro do |db|
    arr = db.query_all "select * from czinfos order by mtime desc", as: RD::Czdata
    arr.uniq!(&.ch_no).to_h { |x| {x.ch_no, x} }
  end

  inp_files = Dir.glob("#{inp_dir}/*.txt")
  puts "#{dname}: total: #{cdata_hash.size}, avail: #{inp_files.size}"

  to_insert = [] of RD::Czdata
  to_delete = [] of Int32

  zdatas = inp_files.each do |inp_file|
    sc_id, _check, ch_no = File.basename(inp_file, ".txt").split('-')
    ch_no = ch_no.to_i

    cbody = ChapUtil.split_lines(File.read(inp_file))

    if cdata = cdata_hash[ch_no]?
      to_delete << cdata.ch_no if cdata.cksum == 0
      cdata.set_czdata(cbody)
    else
      cdata = RD::Czdata.new(
        ch_no: ch_no,
        cbody: cbody,
        title: "",
        chdiv: "",
        uname: uname,
        zorig: "#{dname}/#{sc_id}",
        mtime: File.info(inp_file).modification_time.to_unix
      )
    end

    to_insert << cdata
  end

  puts "to_insert: #{to_insert.size}, to_delete: #{to_delete.size}"

  cz_db.open_tx do |db|
    to_insert.each(&.upsert!(db: db))
    to_delete.each {|ch_no| db.exec "delete from czinfos where ch_no = $1 and cksum = 0", ch_no}
  end
end

old_sname = ARGV[0]
new_sname = ARGV[1]
migrate_seed old_sname, new_sname
