require "crorm"

require "./chflag"
require "./seed_util"
require "../../_util/chap_util"
require "../../zroot/raw_html/raw_rmchap"

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
  class_getter init_sql = <<-SQL
    CREATE TABLE IF NOT EXISTS chinfos(
      ch_no int not null PRIMARY KEY,
      --
      ztitle text NOT NULL DEFAULT '',
      vtitle text NOT NULL DEFAULT '',
      --
      zchdiv text NOT NULL DEFAULT '',
      vchdiv text NOT NULL DEFAULT '',
      --
      spath text NOT NULL DEFAULT '',
      rlink text NOT NULL DEFAULT '',
      --
      cksum text NOT NULL DEFAULT '',
      sizes text NOT NULL DEFAULT '',
      --
      mtime bigint NOT NULL DEFAULT 0,
      uname text NOT NULL default '',
      --
      _flag int NOT NULL default 0
    );
    SQL

  OLD_DIR = "var/zroot/wnchap"
  NEW_DIR = "var/wnapp/chinfo"

  def self.db_path(wn_id : Int32, sname : String)
    "#{NEW_DIR}/#{wn_id}/#{sname}.db3"
  end

  def self.old_db_path(sname : String, sn_id : String)
    "#{OLD_DIR}/#{sname}/#{sn_id}.db3"
  end

  ###

  include Crorm::Model
  schema "chinfos", :sqlite, multi: true

  field ch_no : Int32, pkey: true

  field rlink : String = "" # relative or absolute remote link
  field spath : String = "" # sname/sn_id/sc_id format for tracking

  field ztitle : String = "" # chapter zh title name
  field zchdiv : String = "" # chapter zh division (volume) name

  field vtitle : String = "" # chapter vi title name
  field vchdiv : String = "" # chapter vi division (volume) name

  field cksum : String = "" # check sum of raw chapter text
  field sizes : String = "" # char_count of for title + each part joined by a single ' '

  field mtime : Int64 = 0_i64 # last modified at, optional
  field uname : String = ""   # last modified by, optional

  field _flag : Int32 = 0

  def initialize(@ch_no)
  end

  def initialize(@ch_no, @rlink, @spath, @ztitle, @zchdiv)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "ch_no", @ch_no
      jb.field "uslug", self.uslug

      jb.field "title", @vtitle.empty? ? @ztitle : @vtitle
      jb.field "chdiv", @vchdiv.empty? ? @zchdiv : @vchdiv

      jb.field "psize", self.psize

      jb.field "mtime", @mtime
      jb.field "flags", Chflag.new(@_flag).to_s
    }
  end

  def full_details(can_view : Bool = true)
    {
      rlink: @rlink,
      spath: @spath,
      chsum: can_view ? @chsum : "",

      ztitle: @ztitle,
      zchdiv: @zchdiv,
    }
  end

  def sizes
    @sizes.empty? ? [0] : @sizes.split(' ').map(&.to_i)
  end

  def psize
    @sizes.count(' ')
  end

  def uslug
    str = @vtitle.unicode_normalize(:nfd).gsub(/[\x{0300}-\x{036f}]/, "")
    str.downcase.tr("đ", "d").split(/\W+/, remove_empty: true).first(7).join('-')
  end

  def _href(cpart : Int32 = 1)
    String.build do |io|
      io << @ch_no << '/' << self.uslug << '-'
      io << (cpart < 1 ? self.sizes.size &- 1 : cpart) if cpart != 1
    end
  end

  def add_flag!(flag : Chflag)
    @_flag = (Chflag.new(@_flag) | flag).to_i
  end

  def off_flag!(flag : Chflag)
    @_flag = (Chflag.new(@_flag) - flag).to_i
  end

  ###

  def self.gen_range(pg_no : Int32, limit = 32)
    {chmin, chmax}
  end

  @@select_all_sql : String = @@schema.select_stmt(&.<< " where ch_no > $1 and ch_no <= $2 order by ch_no asc")

  def self.get_all(db, chmin : Int32, chmax : Int32) : Array(self)
    db.query_all(@@select_all_sql, chmin, chmax, as: self)
  end

  @@select_top_sql : String = @@schema.select_stmt(&.<< " where ch_no <= $1 and ch_no > 0 order by ch_no desc limit $2")

  def self.get_top(db, chmax : Int32, limit = 6)
    db.query_all(@@select_top_sql, chmax, limit, as: self)
  end

  def self.find(db, ch_no : Int32)
    db.query_one?(@@schema.select_by_pkey, ch_no, as: self)
  end

  def self.find_prev(db, ch_no : Int32)
    query = @@schema.select_stmt(&.<< " where ch_no < $1 order by ch_no desc limit 1")
    db.query_one?(query, ch_no, as: self)
  end

  def self.find_succ(db, ch_no : Int32)
    query = @@schema.select_stmt(&.<< " where ch_no > $1 order by ch_no asc limit 1")
    db.query_one?(query, ch_no, as: self)
  end

  def self.word_count(db, chmin : Int32, chmax : Int32) : Int32
    query = "select sizes from chinfos where ch_no >= $1 and ch_no <= $2"
    sizes = db.query_all(query, chmin, chmax, as: String)
    sizes.sum(&.split(' ').sum(&.to_i))
  end

  ###

  def self.upsert_zinfos!(db : Crorm::SQ3, input : Array(ZR::Chinfo))
    db.open_tx do |tx|
      query = @@schema.upsert_stmt(keep_fields: %w[rlink spath ztitle zchdiv])
      input.map { |x| self.from(x).upsert!(query, db: tx) }
    rescue ex
      Log.error(exception: ex) { ex.message.colorize.red }
    end
  end

  def self.update_vinfos!(db : Crorm::SQ3, input : Array({Int32, String, String}))
    db.open_tx do |tx|
      query = @@schema.update_stmt(%w[vtitle vchdiv])
      input.each { |ch_no, vtitle, vchdiv| tx.exec(query, vtitle, vchdiv, ch_no) }
    rescue ex
      Log.error(exception: ex) { ex.message.colorize.red }
    end
  end

  def self.get_zinfos(db : Crorm::SQ3, chmin = 1, chmax = 99999)
    ch_nos = [] of Int32
    buffer = String::Builder.new

    db.open_ro do |cnn|
      query = @@schema.select_stmt(%w{ch_no ztitle zchdiv}) do |sql|
        sql << "where ch_no >= $1 and ch_no <= $2"
      end

      # Log.info { query.colorize.yellow }

      cnn.query_each(query, chmin, chmax) do |rs|
        ch_nos << rs.read(Int32)          # read ch_no
        buffer << rs.read(String) << '\n' # read title
        buffer << rs.read(String) << '\n' # read chdiv
      end
    end

    {ch_nos, buffer.to_s}
  end

  def self.gen_vinfos_from_mt(id_map : Array(Int32), zinfos : String, wn_id : Int32 = 0)
    return [] of {Int32, String, String} if id_map.empty?

    href = "#{CV_ENV.m1_host}/_m1/qtran/tl_mulu?wn_id=#{wn_id}"
    tran = HTTP::Client.post(href, body: zinfos, &.body_io.gets_to_end).lines

    id_map.map_with_index do |ch_no, idx|
      {ch_no, tran[idx &* 2], tran[idx &* 2 &+ 1]}
    end
  end

  ###

  CACHE = {} of String => Crorm::SQ3

  def self.load(wn_id : Int32, sname : String, sn_id : String)
    CACHE["#{wn_id}/#{sname}"] ||= begin
      new_path = self.db_path(wn_id, sname)
      old_path = self.old_db_path(sname, sn_id)

      if !File.file?(new_path) && File.file?(old_path)
        File.copy(old_path, new_path)
      end

      self.db(wn_id, sname)
    end
  end

  def self.load(wn_id : Int32, sname : String)
    CACHE["#{wn_id}/#{sname}"] ||= self.db(wn_id, sname)
  end

  def self.init!(wn_id : Int32, sname : String, sn_id : String, force : Bool = false) : Bool
    repo = self.load(wn_id, sname, sn_id)
    return false if !force && self.chap_count(repo) > 0
    import_old!(repo, sname, sn_id) rescue false
  end

  def self.chap_count(db : Crorm::SQ3)
    query = "select ch_no from chinfos order by ch_no desc limit 1"
    db.query_one?(query, as: Int32) || 0
  end

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

  ####

  def self.from(raw_chap : ZR::Chinfo)
    new(
      ch_no: raw_chap.ch_no,
      ztitle: raw_chap.ztitle,
      zchdiv: raw_chap.zchdiv,
      rlink: raw_chap.rlink,
      spath: raw_chap.spath,
    )
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
      if Rmhost.is_remote?(sname)
        new_chap.spath = "#{sname}/#{sn_id}/#{old_chap.s_cid}"
        new_chap.rlink = Rmhost.chap_url(sname, sn_id, old_chap.s_cid)
      end
    when .starts_with?('!')
      sname, sn_id, s_cid = xpath.split(/[\/:]/)
      sname = SeedUtil.fix_sname(sname)

      new_chap.spath = "#{sname}/#{sn_id}/#{s_cid}"
      new_chap.rlink = Rmhost.chap_url(sname, sn_id, s_cid) if Rmhost.is_remote?(sname)
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
