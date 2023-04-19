require "../_raw/raw_yslist"

require "./ysuser"
require "./yscrit"

class YS::Yslist
  include Clear::Model
  self.table = "yslists"

  primary_key type: :serial # pseudo primary key to sastify clear
  column yl_id : Bytes      # real primary key which is a mongodb objectid

  column ysuser_id : Int32 = 0

  column zname : String = "" # original list name
  column vname : String = "" # translated name

  column vslug : String = "" # to search

  column zdesc : String = "" # original description
  column vdesc : String = "" # translated description

  column klass : String = "male" # target demographic: male or female

  column covers : Array(String) = [] of String
  column genres : Array(String) = [] of String

  column utime : Int64 = 0 # list checked at by minutes from epoch

  column info_rtime : Int64 = 0 # list changed at by seconds from epoch
  column book_rtime : Int64 = 0 # list changed at by seconds from epoch

  column _bump : Int32 = 0 # mapped from raw yousuu praiseAt column

  column book_total : Int32 = 0
  column book_count : Int32 = 0

  column like_count : Int32 = 0
  column view_count : Int32 = 0
  column star_count : Int32 = 0

  timestamps

  scope :filter_ysuser do |ysuser_id|
    ysuser_id ? where("ysuser_id = ?", ysuser_id) : self
  end

  scope :sort_by do |order|
    case order
    when "ctime" then self.order_by(id: :desc)
    when "utime" then self.order_by(utime: :desc)
    when "likes" then self.order_by(like_count: :desc)
    when "stars" then self.order_by(star_count: :desc)
    when "views" then self.order_by(view_count: :desc)
    else              self.order_by(_sort: :desc)
    end
  end

  ####################

  def set_name(zname : String, force : Bool = false) : Nil
    self.zname = zname
    self.fix_vname(zname) if force || self.vname.empty?
  end

  def set_desc(zdesc : String, force : Bool = false)
    return if zdesc.empty?
    self.zdesc = zdesc
    self.fix_vdesc(zdesc) if force || self.vdesc.empty?
  end

  def fix_vname(zname : String)
    self.vname = TranUtil.qtran(zname, -5, "txt").as(String)
    self.vslug = "-" + TextUtil.slugify(vname).gsub(/[^\p{L}\p{N}]/, '-')
  end

  def fix_vdesc(zdesc : String)
    self.vdesc = TranUtil.qtran(zdesc, -5, "txt") || ""
  end

  ##################

  def self.preload(ids : Enumerable(Int32))
    ids.empty? ? [] of self : query.where { id.in? ids }
  end

  def self.upsert!(yl_id : String, created_at : Time)
    find({yl_id: yl_id}) || new({yl_id: yl_id, created_at: created_at})
  end

  def update_from(raw_data : RawYslist, rtime : Int64 = Time.utc.to_unix)
    self.set_name(raw_data.zname)
    self.set_desc(raw_data.zdesc)

    self.ysuser_id = raw_data.user.try(&.id) || self.ysuser_id

    self.klass = klass
    self.utime = raw_data.updated_at.to_unix

    self.info_rtime = rtime

    if raw_data.book_total > self.book_total
      self.book_total = raw_data.book_total
    end

    if raw_data.like_count > self.like_count
      self.like_count = raw_data.like_count
    end

    if raw_data.view_count > self.view_count
      self.view_count = raw_data.view_count
    end

    if raw_data.star_count > self.star_count
      self.star_count = raw_data.star_count
    end

    self.updated_at = raw_data.updated_at
  end

  def self.upsert!(raw_data : RawYslist, rtime : Int64 = Time.utc.to_unix)
    inp_list = find({yl_id: raw_data.yl_id}) || new({yl_id: raw_data.yl_id, created_at: raw_data.created_at})

    inp_list.update_from(raw_data, rtime: rtime)
    inp_list.tap(&.save!)
  end

  def self.get_id(yl_id : Bytes)
    PG_DB.query_one("select id from yslists where yl_id = $1", yl_id, as: Int32)
  end

  def self.update_book_total(yl_id : Bytes, total : Int32, rtime : Int64)
    PG_DB.exec <<-SQL, total, rtime, yl_id
      update yslists
      set book_total = $1, book_rtime = $2
      where yl_id = $3 and book_total < $1
      SQL
  end
end
