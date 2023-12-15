require "crorm"

require "../../_data/_data"

require "./tsrepo"
require "./rmstem"

class RD::Wnbook
  ############

  class_getter db : DB::Database = PGDB

  include Crorm::Model
  schema "wninfos", :postgres, strict: false

  field id : Int32 = 0, pkey: true

  field btitle_zh : String = ""
  field btitle_vi : String = ""

  field scover : String = ""
  field bcover : String = ""

  field chap_count : Int32 = 0
  field view_count : Int32 = 0

  field utime : Int64 = 0

  def cover_url
    return "//cdn.chivi.app/covers/#{@bcover}" unless @bcover.empty?
    @scover.blank? ? "//cdn.chivi.app/covers/_blank.webp" : @scover
  end

  def crepo : Tsrepo
    Tsrepo.load!("wn~avail/#{@id}") do |r|
      r.owner = -1
      r.stype = 0_i16

      r.sname = "~avail"
      r.cover = self.cover_url

      r.sn_id = @id
      r.wn_id = @id

      r.zname = @btitle_zh
      r.vname = @btitle_vi

      r.chmax = @chap_count

      r.plock = 0
      r.multp = 3

      r.mtime = @utime

      r.view_count = @view_count
    end
  end

  #########

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "sname", "~avail"
      jb.field "sn_id", @id

      jb.field "zname", @btitle_zh
      jb.field "vname", @btitle_vi

      jb.field "chmax", @chap_count
      jb.field "utime", @utime
    }
  end

  def update!(crawl : Int32 = 1, regen : Bool = false, umode : Int32 = 1) : Nil
    rstems = Rmstem.all_by_wn(@id, uniq: true)
    rstems.reject! { |x| x.rtype > 0 && x.chap_count == 0 }

    return self.update_rtime! if rstems.empty?

    start = 1

    rstems.first(4).each do |rstem|
      rstem.update!(crawl: crawl, regen: regen, umode: umode) if rstem.alive?

      chmax = rstem.chap_count
      next if chmax < start

      clist = rstem.crepo.get_all(start: start, limit: chmax &- start &+ 1)
      self.crepo.upsert_zinfos!(clist)

      start = chmax

      mtime = rstem.update_int
      self.update_stats!(chmax, mtime, persist: false)
    end

    if umode > 0 && @chap_count > 0
      self.crepo.chmax = @chap_count
      self.crepo.update_vinfos!
      self.crepo.upsert!
    else
    end

    # @rtime = Time.utc.to_unix
    self.upsert!(db: @@db)
  end

  def update_stats!(chmax : Int32, mtime : Int64 = Time.utc.to_unix, persist : Bool = false)
    @utime = mtime if @utime < mtime

    if @chap_count < chmax
      @chap_count = chmax
      self.crepo.chmax = chmax
    end

    return unless persist

    query = @@schema.update_stmt(%w{chap_count utime})
    @@db.exec(query, @chap_count, @utime, @id)
  end

  # UPDATE_FIELD_SQL = "update #{@@schema.table} set %s = $1 where id = $2"

  # def update_rtime!(@rtime = Time.utc.to_unix)
  #   query = UPDATE_FIELD_SQL % "rtime"
  #   @@db.exec query, rtime, @id
  #   self
  # end

  #######

  def self.find(wn_id : Int32) : self | Nil
    stmt = self.schema.select_stmt(&.<< " where id = $1")
    self.db.query_one?(stmt, wn_id, as: self)
  end

  def self.find!(wn_id : Int32) : self
    self.find(wn_id) || raise "wnovel [#{wn_id}] not found!"
  end

  ###
end
