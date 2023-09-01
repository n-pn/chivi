require "crorm/model"

require "./_data"
require "./_util"
require "./_raw/raw_yscrit"

# require "../../mt_ai/core/qt_core"

class YS::YsuserForm
  class_getter db : DB::Database = PG_DB

  include Crorm::Model
  schema "ysusers", :postgres

  field id : Int32, pkey: true

  field zname : String = ""
  field vname : String = ""
  field vslug : String = ""

  field y_avatar : String = ""

  # field like_count : Int32 = 0
  # field star_count : Int32 = 0

  # field list_total : Int32 = 0
  # field crit_total : Int32 = 0

  # field info_rtime : Int64 = 0

  timestamps

  def initialize(@id)
  end

  def update!(raw : EmbedUser, force : Bool = false)
    changed = false

    if force || @zname.empty?
      changed = @zname != raw.name

      @zname = raw.name
      @vname = MT::QtCore.tl_hvname(@zname)
      @vslug = TextUtil.slugify(@vname)
    end

    if force || @y_avatar.empty?
      changed ||= @y_avatar != raw.avatar
      @y_avatar = raw.avatar
    end

    upsert! if force || changed
  end

  # def set_stat(stat : RawYsuser, rtime : Int64)
  #   self.like_count = stat.like_count
  #   self.star_count = stat.star_count

  #   self.set_crit_total(stat.crit_total)
  #   self.set_list_total(stat.list_total)

  #   self
  # end

  ###############

  def self.load(id : Int32)
    find(id: id) || new(id: id)
  end

  def self.bulk_upsert!(raws : Enumerable(EmbedUser))
    raws.map do |raw|
      self.load(raw.id).update!(raw)
    rescue ex
      Log.error(exception: ex) { raw.to_json }
    end
  end

  def self.update_crit_total(id : Int32, total : Int32, rtime : Int64)
    PG_DB.exec <<-SQL, total, rtime, id
      update #{@@table}
      set crit_total = $1, crit_rtime = $2
      where id = $3 and crit_total < $1
      SQL
  end

  def self.update_list_total(id : Int32, total : Int32, rtime : Int64)
    PG_DB.exec <<-SQL, total, rtime, id
      update #{@@table}
      set list_total = $1, list_rtime = $2
      where id = $3 and list_total < $1
      SQL
  end
end
