require "colorize"
require "../../src/rdapp/data/czdata"

TXT_DIR = "/mnt/serve/chivi.all/ztext"
DB3_DIR = "var/stems"

def migrate_seed(old_sname : String, new_sname : String = old_sname)
  txt_dir = File.join(TXT_DIR, old_sname)
  sn_ids = Dir.children(txt_dir)

  sn_ids.each do |sn_id|
    dname = "#{new_sname}/#{sn_id}"
    migrate_book(inp_dir: File.join(txt_dir, sn_id), dname: dname)
  end
end

SELECT_SQL = <<-SQL
  select ch_no, zorig, cksum from czinfos where zorig <> ''
SQL

def migrate_book(inp_dir : String, dname : String)
  inp_files = Dir.glob("#{inp_dir}/*.gbk")

  mapping = RD::Czdata.db(dname).open_ro do |db|
    db.query_all(SELECT_SQL, as: {Int32, String, Int64}).to_h do |ch_no, zorig, cksum|
      {zorig.split('/').last, {ch_no, cksum}}
    end
  end

  puts "total: #{mapping.size}, avail: #{inp_files.size}"

  inp_files.each do |inp_file|
    sc_id = File.basename(inp_file, ".gbk")
    unless found = mapping[sc_id]?
      puts "#{sc_id} is not mapped".colorize.red
      next
    end

    ch_no, cksum = found
    if cksum != 0
      puts "#{inp_file} archived!".colorize.blue
      next
    end

    puts "#{inp_file} not archived!".colorize.green
  end
end

# migrate_seed "!69shu", "rm!69shuba.com"
# migrate_book "#{TXT_DIR}/!69shu/795", "rm!69shuba.com/795"
migrate_book "#{TXT_DIR}/!rengshu/15", "rm!rengshu.com/15"
