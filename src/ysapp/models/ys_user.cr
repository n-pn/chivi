require "./_base"
require "../../mt_sp/sp_core"

class YS::Ysuser
  include Clear::Model
  self.table = "ysusers"

  primary_key type: :serial
  column yu_id : Int32 # origin yousuu id

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
    self.vname = SP::MtCore.tl_name(zname)
    self.vslug = TextUtil.slugify(self.vname)
  end

  def set_avatar(avatar : String)
    return if avatar.empty?
    self.y_avatar = avatar
  end

  def set_data(data : EmbedUser)
    self.set_name(data.name) unless data.name.empty?
    self.set_avatar(data.avatar) unless data.avatar.empty?
  end

  def set_stat(stat : RawYsUser, rtime : Int64)
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

  def self.load(yu_id : Int32)
    find({yu_id: yu_id}) || new({yu_id: yu_id})
  end

  def self.upsert!(raw_user : EmbedUser)
    find({yu_id: raw_user.id}) || begin
      entry = new({yu_id: raw_user.id})
      entry.set_data(raw_user)
      entry.tap(&.save!)
    end
  end

  def self.upsert!(yu_id : Int32, zname : String)
    find({yu_id: yu_id}) || begin
      entry = new({yu_id: yu_id, zname: zname}).tap(&.fix_name)
      entry.tap(&.save!)
    end
  end

  def self.preload(ids : Enumerable(Int32))
    ids.empty? ? [] of self : query.where { id.in? ids }
  end
end
