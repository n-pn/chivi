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
  belongs_to yscrit : Yscrit

  column stime : Int64 = 0 # list checked at by minutes from epoch

  column like_count : Int32 = 0
  column repl_count : Int32 = 0 # reply count, optional

  timestamps

  getter ztext : String { load_ztext_from_disk }
  getter vhtml : String { load_vhtml_from_disk }

  def vdict
    YsUtil.vdict(self.yscrit.nvinfo_id)
  end

  def zip_path(type = "zh")
    crit_uuid = self.yscrit.origin_id
    prefix = crit_uuid[0..2]
    "var/ysapp/repls/#{prefix}-#{type}/#{crit_uuid}.zip"
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
      return ERROR_BODY unless tran = TranUtil.qtran(ztext, vdict.dname)
      html = tran.split('\n').map { |x| "<p>#{x}</p>" }.join('\n')
    end

    save_vhtml_to_disk(html) if persist
    html
  end

  def save_vhtml_to_disk(vhtml : String)
    zip_path = self.zip_path("vi")
    out_path = zip_path.sub("repls", "repls.tmp").sub(".zip", "")
    Dir.mkdir_p(out_path)

    out_html = "#{out_path}/#{self.origin_id}.htm"
    File.write(out_html, vhtml)

    `zip -FS -jrq "#{zip_path}" #{out_html}`
  end

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

  def self.upsert!(origin_id : String, created_at : Time)
    find({origin_id: origin_id}) || begin
      new({id: gen_id(origin_id), origin_id: origin_id, created_at: created_at})
    end
  end
end
