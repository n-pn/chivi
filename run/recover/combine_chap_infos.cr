require "../../src/rdapp/data/chinfo"
require "../../src/rdapp/_raw/rmhost"

struct OldChap
  include Crorm::Model
  schema "chinfos", :sqlite, multi: true

  field ch_no : Int32, pkey: true
  field s_cid : Int32

  field title : String
  field chvol : String

  field mtime : Int64
  field uname : String

  PATCH_SQL = <<-SQL
    insert into chinfos(ch_no, rlink, spath, ztitle, zchdiv, mtime, uname)
    values ($1, $2, $3, $4, $5)
    SQL

  def upsert!(db, sname, sn_id, rmhost)
    spath = "rm#{sname}/#{sn_id}/#{s_cid}"
    rlink = rmhost ? rmhost.chap_url(sn_id, s_cid) : ""

    db.exec PATCH_SQL, @ch_no, rlink, spath, @title, @chvol, @mtime, @uname
  end
end

OLD_CHMAX_SQL = "select coalesce(ch_no, 0) from chinfos order by ch_no desc limit 1"
NEW_CHMAX_SQL = "select coalesce(ch_no, 0) from chinfos order by ch_no desc limit 1"
FETCH_OLD_SQL = "select * from chinfos where ch_no > $1 order by ch_no asc"

def copy_db(old_file, new_sname, sn_id, rmhost)
  new_db = RD::Chinfo.db("rm#{new_sname}/#{sn_id}")
  old_db = Crorm::SQ3.new(old_file)
  new_max = new_db.query_one(NEW_CHMAX_SQL, as: Int32)
  old_max = old_db.query_one(OLD_CHMAX_SQL, as: Int32)

  if new_max >= old_max
    # File.rename(old_file, old_file + ".old")
    puts "- #{old_file} not newer (#{old_max} => #{new_max}), deleted".colorize.red
    return
  end

  puts "#{old_file} => #{new_db.db_path}: #{old_max} => #{new_max}".colorize.yellow
  inputs = old_db.query_all(FETCH_OLD_SQL, new_max, as: OldChap)

  new_db.open_tx do |db|
    inputs.each(&.upsert!(db, new_sname, sn_id, rmhost))
  end

  # File.rename(old_file, old_file + ".old")
end

OLD_DIR = "/mnt/serve/chivi.app/chaps/old-infos"
OLD_EXT = "-infos.db"

def combine(new_sname, old_sname = new_sname.split('.').first)
  old_dir = File.join(OLD_DIR, old_sname)
  return unless File.directory?(old_dir)

  old_files = Dir.glob File.join(old_dir, "*#{OLD_EXT}")
  rmhost = Rmhost.from_name!(new_sname) rescue nil

  old_files.each do |old_file|
    sn_id = File.basename(old_file, "#{OLD_EXT}")

    if sn_id[0] == '-'
      File.delete old_file
      next
    end

    copy_db old_file, new_sname, sn_id, rmhost
  rescue ex
    puts [old_file, ex]
  end
end

# combine "!69shuba.com", "69shu"
combine "!zxcs.me", "zxcs_me"

# combine "!133txt.com"
# combine "!biqugee.com"
# combine "!bxwxorg.com"

# combine "!hetushu.com"
# combine "!uukanshu.com"

# combine "!xbiquge.bz"
# combine "!zsdade.com"
# combine "!tasim.net"

# combine "!shubaow.net"
# combine "!rengshu.com"
# combine "!duokanba.com", "!duokan8"
# combine "!paoshu8.com"
# combine "!egyguard.net"

# # combine "!b5200.org"
# combine "!biqu5200.net", "!biqu5200"
# combine "!jx.la", "!jx_la"
# combine "!piaotian.com", "!ptwxz"
# # combine "!egyguard.com"
# combine "!nofff.com"
