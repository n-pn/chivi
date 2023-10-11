require "crorm"

require "../../rdapp/_raw/raw_rmchap"

class WN::OldChap
  include DB::Serializable
  include DB::Serializable::NonStrict

  property ch_no : Int32 # chaper index number
  property s_cid : Int32 # chapter fname in disk/remote

  property title : String = "" # chapter title
  property chdiv : String = "" # volume name

  property vtitle : String = "" # translated title
  property vchdiv : String = "" # translated volume name

  property mtime : Int64 = 0   # last modification time
  property uname : String = "" # last modified by username

  property c_len : Int32 = 0 # chars count
  property p_len : Int32 = 0 # parts count

  property _path : String = "" # file locator
  property _flag : Int32 = 0   # marking states

end

class WN::Chinfo
  OLDER_DIR = "/2tb/app.chivi/var/zchap/infos"

  def self.import_old!(repo, sname : String, sn_id : String) : Bool
    db_paths = {
      "#{OLDER_DIR}/#{sname}/#{sn_id}.db",
      "#{OLDER_DIR}/#{sname}/#{sn_id}.db.old",
      "#{OLDER_DIR}/#{sname}/#{sn_id}-infos.db",
      "#{OLDER_DIR}/#{sname}/#{sn_id}-infos.db.old",
    }

    db_paths.each do |db_path|
      next unless File.file?(db_path)

      old_chaps = DB.open("sqlite3:#{db_path}?immutable=1") do |db|
        query = "select * from chaps where ch_no > 0 order by ch_no asc"
        db.query_all(query, as: OldChap)
      end

      next if old_chaps.empty?

      new_chaps = old_chaps.map { |old_chap| self.from(old_chap, sname, sn_id) }
      repo.open_tx { |db| new_chaps.each(&.upsert!(db: db)) }

      break
    end

    true
  end

  def self.from(old_chap : OldChap, sname : String, sn_id : String)
    new_chap = Chinfo.new(ch_no: old_chap.ch_no)
    new_chap.mtime = old_chap.mtime
    new_chap.uname = old_chap.uname

    new_chap.ztitle = CharUtil.to_canon(old_chap.title)
    new_chap.zchdiv = CharUtil.to_canon(old_chap.chdiv)

    new_chap.vtitle = old_chap.vtitle
    new_chap.vchdiv = old_chap.vchdiv

    case xpath = old_chap._path
    when ""
      if Rmhost.remote?(sname)
        new_chap.spath = "#{sname}/#{sn_id}/#{old_chap.s_cid}"
        new_chap.rlink = Rmhost.chap_url(sname, sn_id, old_chap.s_cid)
      end
    when .starts_with?('!')
      sname, sn_id, s_cid = xpath.split(/[\/:]/)
      sname = SeedUtil.fix_sname(sname)

      new_chap.spath = "#{sname}/#{sn_id}/#{s_cid}"
      new_chap.rlink = Rmhost.chap_url(sname, sn_id, s_cid) if Rmhost.remote?(sname)
    when .starts_with?('/')
      new_chap.spath = "#{sname}/#{sn_id}/#{old_chap.s_cid}"
      new_chap.rlink = Rmhost.chap_url(sname, sn_id, old_chap.s_cid)
    when .starts_with?("http")
      uri = URI.parse(xpath)
      host = Rmhost.from_host!(uri.host.as(String)) rescue nil

      if host
        new_chap.rlink = xpath
        sn_id, s_cid = host.extract_ids(uri.path.as(String))
        new_chap.spath = "#{host.seedname}/#{sn_id}/#{s_cid}"
      end
    end

    new_chap
  end
end
