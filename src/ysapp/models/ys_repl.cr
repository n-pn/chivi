require "./_base"
require "./_util"

require "./ys_crit"
require "./ys_user"

class YS::Ysrepl
  include Clear::Model
  self.table = "ysrepls"

  primary_key
  column origin_id : String

  belongs_to ysuser : Ysuser

  column yscrit_id : Int64 = 0_i64

  column stime : Int64 = 0 # list checked at by minutes from epoch

  column y_cid : String = ""
  column y_uid : Int32 = 0

  column ztext : String = ""
  column vhtml : String = ""

  column like_count : Int32 = 0
  column repl_count : Int32 = 0 # reply count, optional

  timestamps

  scope :filter_yscrit do |yscrit_id|
    yscrit_id ? where("yscrit_id = #{yscrit_id}") : self
  end

  scope :filter_ysuser do |ysuser_id|
    ysuser_id ? where("ysuser_id = #{ysuser_id}") : self
  end

  scope :sort_by do |order|
    case order
    when "ctime" then self.order_by(id: :desc)
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
    y_rid = self.origin_id

    dir_path = "#{TXT_DIR}/#{y_rid[0..3]}-zh"
    Dir.mkdir_p(dir_path)

    file_path = File.join(dir_path, "#{y_rid}.txt")
    File.write(file_path, ztext)

    Log.debug { "saved repl ztext to #{file_path}" }
  end

  EMPTY_BODY = "<p><em>Không có nội dung</em></p>"
  ERROR_BODY = "<p><em>Máy dịch gặp sự cố</em></p>"

  def fix_vhtml(ztext = self.ztext)
    if ztext.empty?
      self.vhtml = EMPTY_BODY
    elsif vtext = TranUtil.qtran(ztext, wn_id: 0)
      self.vhtml = TranUtil.txt_to_htm(vtext)
    else
      self.vhtml = ERROR_BODY
    end
  end

  ##############

  def self.gen_id(origin_id : String)
    origin_id[12..].to_i64(base: 16)
  end

  def self.load(origin_id : String)
    find({origin_id: origin_id}) || begin
      new({id: gen_id(origin_id), origin_id: origin_id})
    end
  end

  def self.bulk_upsert(raw_repls : Array(RawYsRepl), save_text : Bool = true)
    raw_repls.each do |raw_repl|
      out_repl = self.load(raw_repl.y_rid)

      out_crit = Yscrit.load(raw_repl.y_cid)
      out_user = Ysuser.upsert!(raw_repl.user)

      out_repl.yscrit_id = out_crit.id

      out_repl.y_uid = out_user.y_uid
      out_repl.ysuser_id = out_user.id # TODO: remove this

      if save_text || out_repl.ztext.empty?
        out_repl.set_ztext(raw_repl.ztext)
      end

      out_repl.like_count = raw_repl.like_count
      out_repl.repl_count = raw_repl.repl_count

      out_repl.created_at = raw_repl.created_at
      out_repl.updated_at = raw_repl.created_at

      out_repl.save!
    end
  end
end
