require "./_base"
require "./_util"

require "./yslist"
require "./ysbook"
require "./ysuser"

require "./_raw/raw_yscrit"

class YS::Yscrit
  include Clear::Model
  self.table = "yscrits"

  primary_key type: :serial
  column yc_id : Bytes

  column nvinfo_id : Int32 = 0
  column ysbook_id : Int32 = 0

  column ysuser_id : Int32 = 0
  column yslist_id : Int32 = 0

  column ztext : String = ""
  column vhtml : String = ""

  column vi_mt : String? = nil
  column vi_bd : String? = nil
  column vi_ms : String? = nil
  column en_bd : String? = nil
  column en_dl : String? = nil
  column en_ms : String? = nil

  column stars : Int32 = 3 # voting 1 2 3 4 5 stars
  column vtags : Array(String) = [] of String

  column repl_count : Int32 = 0
  column like_count : Int32 = 0

  timestamps

  scope :sort_by do |order|
    case order
    when "ctime" then self.order_by(id: :desc)
    when "utime" then self.order_by(updated_at: :desc)
    when "likes" then self.order_by(like_count: :desc, stars: :desc)
    else              self.order_by(_sort: :desc, stars: :desc)
    end
  end

  ZIP_DIR = "var/zroot/yousuu/crits-zip"
  TXT_DIR = "var/zroot/yousuu/crits-txt"

  private def group_by
    self.yc_id.first(2).join(&.to_s(16))
  end

  def zip_path(type = "zh")
    "#{ZIP_DIR}/#{group_by}-#{type}.zip"
  end

  def tmp_path(type = "zh")
    "#{TXT_DIR}/#{group_by}-#{type}"
  end

  def filename(ext = "txt")
    "#{self.yc_id}.#{ext}"
  end

  # def load_btran_from_disk : String
  #   load_htm_from_disk("bv", persist: true) { |ztext| TranUtil.btran(ztext) }
  # end

  # def load_deepl_from_disk : String
  #   load_htm_from_disk("de", persist: true) { |ztext| TranUtil.deepl(ztext) }
  # end

  # private def load_htm_from_disk(type : String, persist : Bool = true, &)
  #   YsUtil.read_zip(self.zip_path(type), filename("htm")) do
  #     ztext = self.ztext

  #     if !ztext.empty? && (vtext = yield ztext)
  #       html = "<p>#{vtext.gsub('\n', "</p><p>")}</p>"
  #     else
  #       html = "<p>$$$</p>"
  #       persist = false
  #     end

  #     save_data_to_disk(html, type: type, ext: "htm") if persist
  #     html
  #   end
  # rescue err
  #   Log.error(exception: err) { "error loading #{type} html for #{yc_id} of #{ysbook_id}" }
  #   "<p>$$$</p>"
  # end

  # def save_data_to_disk(data : String, type : String, ext : String) : Nil
  #   dir_path = self.tmp_path(type)
  #   Dir.mkdir_p(dir_path)

  #   file_path = File.join(dir_path, filename(ext))
  #   File.write(file_path, data)

  #   zip_path = self.zip_path(type)
  #   YsUtil.zip_data(zip_path, dir_path)

  #   Log.debug { "save #{file_path} to #{zip_path}" }
  # end

  ###################

  def self.load(id : Int32)
    find({id: id})
  end

  def self.find(yc_id : Bytes)
    query.where("yc_id = ?", yc_id).first
  end

  def self.get_id(yc_id : Bytes)
    PG_DB.query_one("select id from yscrits where yc_id = $1", yc_id, as: Int32)
  end

  def self.set_vi_bd(vi_bd : String, id : Int32)
    PG_DB.exec "update yscrits set vi_bd = $1 where id = $2", vi_bd, id
  end
end
