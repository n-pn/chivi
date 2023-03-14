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

  getter ztext : String { load_ztext_from_disk }
  getter vhtml : String { load_vhtml_from_disk }

  ZIP_DIR = "var/ysapp/repls-zip"
  TXT_DIR = "var/ysapp/repls-txt"

  private def group_by
    self.origin_id[0..3]
  end

  def zip_path(type = "zh")
    "#{ZIP_DIR}/#{group_by}-#{type}.zip"
  end

  def tmp_path(type = "zh")
    "#{TXT_DIR}/#{group_by}-#{type}"
  end

  def filename(ext = "txt")
    "#{self.origin_id}.#{ext}"
  end

  def load_ztext_from_disk : String
    YsUtil.read_zip(zip_path("zh"), "#{origin_id}.txt") { "$$$" }
  rescue err
    Log.error(exception: err) { err.message }
    "$$$"
  end

  def load_vhtml_from_disk : String
    YsUtil.read_zip(zip_path("vi"), "#{origin_id}.htm") do
      render_vhtml_from_ztext(persist: true)
    end
  rescue err
    Log.error(exception: err) { "error loading vhtml for #{origin_id} of #{yscrit_id}" }
    "<p><em class=err>Lỗi hệ thống! Mời liên hệ ban quản trị</em></p>"
  end

  ERROR_BODY = "<p><em class=err>Lỗi dịch phản hồi!</em></p>"

  def render_vhtml_from_ztext(persist : Bool = true)
    ztext = self.ztext

    if ztext.empty? || ztext == "$$$"
      html = "<p><em>Không có nội dung</em></p>"
    else
      return ERROR_BODY unless tran = TranUtil.qtran(ztext, 0)
      html = tran.split('\n').map { |x| "<p>#{x}</p>" }.join('\n')
    end

    save_data_to_disk(html, "vi", ".htm") if persist
    html
  end

  def save_data_to_disk(data : String, type : String, ext : String) : Nil
    dir_path = self.tmp_path(type)
    Dir.mkdir_p(dir_path)

    file_path = File.join(dir_path, self.filename(ext))
    File.write(file_path, data)

    zip_path = self.zip_path(type)
    YsUtil.zip_data(zip_path, dir_path)

    Log.debug { "save #{file_path} to #{zip_path}" }
  end

  # def set_ztext(ztext : String)
  #   return if ztext.empty?
  #   self.ztext = ztext
  #   self.fix_vhtml
  # end

  # def fix_vhtml(dname = self.yscrit.nvinfo.dname)
  #   self.vhtml = CV::BookUtil.cv_lines(ztext, dname, mode: :html)
  # end

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

      out_repl.save_data_to_disk(raw_repl.ztext, "zh", "txt") if save_text

      out_repl.like_count = raw_repl.like_count
      out_repl.repl_count = raw_repl.repl_count

      out_repl.created_at = raw_repl.created_at

      out_repl.save!
    end
  end
end
