require "./_base"
require "./_util"

require "./yscrit"
require "./ysuser"

class YS::Ysrepl
  include Clear::Model
  self.table = "ysrepls"

  primary_key type: :serial

  column yr_id : Bytes # mongodb booklist objectid
  column yc_id : Bytes # mongodb review objectid

  column yscrit_id : Int32 = 0

  column ysuser_id : Int32 = 0
  column touser_id : Int32 = 0 # to ysuser id

  column ztext : String = ""
  column vhtml : String = ""

  column like_count : Int32 = 0
  column repl_count : Int32 = 0 # reply count, optional

  column info_rtime : Int64 = 0 # list checked at by minutes from epoch

  timestamps

  scope :filter_yscrit do |yscrit_id|
    yscrit_id ? where("yscrit_id = #{yscrit_id}") : self
  end

  scope :filter_ysuser do |ysuser_id|
    ysuser_id ? where("ysuser_id = #{ysuser_id}") : self
  end

  scope :sort_by do |order|
    case order
    when "ctime" then self.order_by(created_at: :asc)
    when "likes" then self.order_by(like_count: :desc)
    else              self.order_by(created_at: :desc)
    end
  end

  def set_ztext(ztext : String)
    return if ztext.empty?
    spawn save_ztext_copy(ztext)

    self.ztext = ztext
    self.fix_vhtml(ztext)
  end

  TXT_DIR = "var/ysapp/repls-txt"

  def save_ztext_copy(ztext : String) : Nil
    yr_id = self.yr_id

    dir_path = "#{TXT_DIR}/#{yr_id[0..3]}-zh"
    Dir.mkdir_p(dir_path)

    file_path = File.join(dir_path, "#{yr_id}.txt")
    File.write(file_path, ztext)

    Log.debug { "saved repl ztext to #{file_path}" }
  end

  EMPTY_BODY = "<p><em>Không có nội dung</em></p>"
  ERROR_BODY = "<p><em>Máy dịch gặp sự cố</em></p>"

  def fix_vhtml(ztext = self.ztext)
    if ztext.empty?
      self.vhtml = EMPTY_BODY
    elsif vtext = TranUtil.qtran(ztext, wn_id: 0, format: "txt")
      self.vhtml = TranUtil.txt_to_htm(vtext)
    else
      self.vhtml = ERROR_BODY
    end
  end

  ##############

  def self.load(yr_id : String)
    find({yr_id: yr_id.hexbytes}) || new({yr_id: yr_id.hexbytes})
  end

  def self.bulk_upsert!(raw_repls : Array(RawYsrepl), save_text : Bool = true)
    crit_ids = {} of Bytes => Int32

    raw_repls.map do |raw_repl|
      out_repl = self.load(raw_repl.yr_id)

      out_repl.yc_id = raw_repl.yc_id.hexbytes
      out_repl.yscrit_id = crit_ids[out_repl.yc_id] ||= Yscrit.get_id(out_repl.yc_id)

      out_repl.ysuser_id = raw_repl.user.id
      out_repl.touser_id = raw_repl.to_user.try(&.id) || 0

      out_repl.ztext = raw_repl.ztext

      # if save_text || out_repl.ztext.empty?
      #   out_repl.set_ztext(raw_repl.ztext)
      # end

      out_repl.like_count = raw_repl.like_count
      out_repl.repl_count = raw_repl.repl_count

      out_repl.created_at = raw_repl.created_at
      out_repl.updated_at = raw_repl.created_at

      out_repl
    end
  end

  def self.update_yscrit_id(ids : Enumerable(Int32), yscrit_id : Int32)
    PG_DB.exec <<-SQL, yscrit_id, ids
      update ysrepls set yscrit_id = $1 where ids = any ($2)
      SQL
  end

  def self.update_fkeys(ids : Enumerable(Int32))
    PG_DB.exec <<-SQL, ids
      update ysrepls set
        yscrit_id = ( select id from yscrits where yscrits.yc_id = ysrepls.yc_id ),
      where ids = any ($2)
      SQL
  end
end
