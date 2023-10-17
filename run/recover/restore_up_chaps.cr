require "../../src/rdapp/data/chinfo"
require "../../src/rdapp/_raw/rmhost"

INP = "var/zroot/chinfo"
OUT = "var/stems"

struct OldChap
  include Crorm::Model
  schema "chinfos", :sqlite, multi: true

  field ch_no : Int32, pkey: true

  field rlink : String = "" # relative or absolute remote link
  field spath : String = "" # sname/sn_id/sc_id format for tracking

  field ztitle : String = "" # chapter zh title name
  field zchdiv : String = "" # chapter zh division (volume) name

  field cksum : String = "" # check sum of raw chapter text

  PATCH_SQL = <<-SQL
    insert into chinfos(ch_no, rlink, spath, ztitle, zchdiv, cksum)
    values ($1, $2, $3, $4, $5, $6)
    SQL

  def upsert!(db, sname, sn_id, rmhost)
    sc_id = @spath.split('/').last
    spath = "rm#{sname}/#{sn_id}/#{sc_id}"
    rlink = rmhost ? rmhost.chap_url(sn_id, sc_id) : ""

    db.exec PATCH_SQL, @ch_no, rlink, spath, @ztitle, @zchdiv, @cksum
  end
end

def combine(old_sname, new_sname = old_sname)
  rmhost = Rmhost.from_name!(new_sname) rescue nil

  old_dir = File.join(INP, old_sname)

  old_files = Dir.glob File.join(old_dir, "*.db3")

  old_files.each do |old_file|
    sn_id = File.basename(old_file, ".db3")

    if sn_id[0] == '-' || sn_id.ends_with?(".db3")
      File.delete old_file
      next
    end

    copy_db old_file, new_sname, sn_id, rmhost
  end
end

CHMAX_SQL = "select coalesce(ch_no, 0) from chinfos order by ch_no desc limit 1"
FETCH_SQL = "select * from chinfos where ch_no > $1 order by ch_no asc"

def copy_db(old_file, new_sname, sn_id, rmhost)
  new_db = RD::Chinfo.db("rm#{new_sname}/#{sn_id}")
  old_db = Crorm::SQ3.new(old_file)
  new_max = new_db.query_one(CHMAX_SQL, as: Int32) rescue 0
  old_max = old_db.query_one(CHMAX_SQL, as: Int32) rescue 0

  puts "#{old_file} => #{new_db.db_path}: #{old_max} ==> #{new_max}"

  if new_max >= old_max
    File.delete(old_file)
    puts "- #{old_file} not newer, deleted".colorize.red
    return
  end

  puts "migrating!!".colorize.green
  inputs = old_db.query_all(FETCH_SQL, new_max, as: OldChap)

  new_db.open_tx do |db|
    inputs.each(&.upsert!(db, new_sname, sn_id, rmhost))
  end
end

# combine "!69shuba.com"
# combine "!133txt.com"
# combine "!biqugee.com"
# combine "!biquluo.cc"
# combine "!bxwxorg.com"
# combine "!zxcs.me"
# combine "!hetushu.com"
# combine "!uukanshu.com"

# combine "!xbiquge.bz"
# combine "!zsdade.com"
# combine "!tasim.net"

# combine "!shubaow.net"
# combine "!rengshu.com"
# combine "!duokanba.com"
# combine "!paoshu8.com"
# combine "!egyguard.net"

# combine "!b5200.org"
# combine "!biqu5200.net"
# combine "!jx.la"
# combine "!piaotian.com"
# combine "!egyguard.com"
# combine "!nofff.com"
