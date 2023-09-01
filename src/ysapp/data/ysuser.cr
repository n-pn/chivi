require "./_base"
require "../../mt_ai/core/qt_core"

class YS::Ysuser
  include Clear::Model
  self.table = "ysusers"

  primary_key type: :serial # origin yousuu id

  column zname : String = ""
  column vname : String = ""
  column vslug : String = ""

  column y_avatar : String = ""
  column v_avatar : String = ""

  column like_count : Int32 = 0
  column star_count : Int32 = 0

  column list_total : Int32 = 0
  column list_count : Int32 = 0

  column crit_total : Int32 = 0
  column crit_count : Int32 = 0

  column repl_total : Int32 = 0
  column repl_count : Int32 = 0

  column info_rtime : Int64 = 0
  column crit_rtime : Int64 = 0
  column list_rtime : Int64 = 0

  timestamps

  def set_name(zname : String)
    self.zname = zname
    self.vname = MT::QtCore.tl_hvname(zname)
    self.vslug = TextUtil.slugify(self.vname)
  end

  def set_avatar(avatar : String)
    return if avatar.empty?
    self.y_avatar = avatar
  end

  def set_data(raw : EmbedUser, force : Bool = false, persist : Bool = false)
    if force || self.zname.empty?
      self.set_name(raw.name)
    end

    if !raw.avatar.empty? && (force || self.y_avatar.empty?)
      self.set_avatar(raw.avatar)
    end

    self.save! if persist || !id_column.defined?
  end

  def set_stat(stat : RawYsuser, rtime : Int64)
    self.like_count = stat.like_count
    self.star_count = stat.star_count

    self.set_crit_total(stat.crit_total)
    self.set_list_total(stat.list_total)

    self
  end

  def set_crit_total(value : Int32)
    self.crit_total = value if value > self.crit_total
  end

  def set_list_total(value : Int32)
    self.list_total = value if value > self.list_total
  end

  ###############

  def self.load(id : Int32)
    find({id: id}) || new({id: id})
  end

  def self.upsert!(raw_user : EmbedUser)
    find({id: raw_user.id}) || begin
      entry = new({id: raw_user.id})
      entry.set_data(raw_user)
      entry.tap(&.save!)
    end
  end

  def self.upsert!(id : Int32, zname : String)
    find({id: id}) || begin
      entry = new({id: id})
      entry.set_name(zname)
      entry.tap(&.save!)
    end
  end

  def self.preload(ids : Array(Int32))
    ids.empty? ? [] of self : query.where("id = any(?)", ids)
  end

  def self.bulk_upsert!(raw_users : Enumerable(EmbedUser))
    raw_users.map do |raw_user|
      out_user = self.load(raw_user.id)
      out_user.set_data(raw_user, persist: true)
      out_user
    end
  end

  def self.update_crit_total(id : Int32, total : Int32, rtime : Int64)
    PG_DB.exec <<-SQL, total, rtime, id
      update ysusers
      set crit_total = $1, crit_rtime = $2
      where id = $3 and crit_total < $1
      SQL
  end

  def self.update_list_total(id : Int32, total : Int32, rtime : Int64)
    PG_DB.exec <<-SQL, total, rtime, id
      update ysusers
      set list_total = $1, list_rtime = $2
      where id = $3 and list_total < $1
      SQL
  end
end
