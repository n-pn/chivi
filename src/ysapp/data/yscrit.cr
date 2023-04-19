require "./_base"
require "./_util"

require "./ys_list"
require "./ys_book"
require "./ys_user"

require "../_raw/raw_yscrit"

class YS::Yscrit
  include Clear::Model
  self.table = "yscrits"

  primary_key type: :serial
  column yc_id : Bytes #  mongodb objectid

  column yl_id : Bytes = "".hexbytes # mongodb yslist objectid

  column nvinfo_id : Int32 = 0
  column ysbook_id : Int32 = 0

  column ysuser_id : Int32 = 0
  column yslist_id : Int32 = 0

  column ztext : String = ""
  column vhtml : String = ""

  column stars : Int32 = 3 # voting 1 2 3 4 5 stars

  column ztags : Array(String) = [] of String
  column vtags : Array(String) = [] of String

  column utime : Int64 = 0 # list changed at by seconds from epoch

  column info_rtime : Int64 = 0
  column repl_rtime : Int64 = 0

  column repl_total : Int32 = 0
  column repl_count : Int32 = 0

  column like_count : Int32 = 0

  timestamps

  scope :sort_by do |order|
    case order
    when "ctime" then self.order_by(id: :desc)
    when "utime" then self.order_by(utime: :desc)
    when "likes" then self.order_by(like_count: :desc, stars: :desc)
    else              self.order_by(_sort: :desc, stars: :desc)
    end
  end

  ZIP_DIR = "var/ysapp/crits-zip"
  TXT_DIR = "var/ysapp/crits-txt"

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

  def fix_vhtml(ztext = self.ztext, persist : Bool = false) : Nil
    return if ztext.empty?

    vtext = TranUtil.qtran(ztext, self.nvinfo_id, "txt") || "$$$"
    self.vhtml = "<p>#{vtext.gsub('\n', "</p><p>")}</p>"

    self.save! if persist
  end

  def load_btran_from_disk : String
    load_htm_from_disk("bv", persist: true) { |ztext| TranUtil.btran(ztext) }
  end

  def load_deepl_from_disk : String
    load_htm_from_disk("de", persist: true) { |ztext| TranUtil.deepl(ztext) }
  end

  private def load_htm_from_disk(type : String, persist : Bool = true, &)
    YsUtil.read_zip(self.zip_path(type), filename("htm")) do
      ztext = self.ztext

      if !ztext.empty? && (vtext = yield ztext)
        html = "<p>#{vtext.gsub('\n', "</p><p>")}</p>"
      else
        html = "<p>$$$</p>"
        persist = false
      end

      if persist
        save_data_to_disk(html, type: type, ext: "htm")
      end

      html
    end
  rescue err
    Log.error(exception: err) { "error loading #{type} html for #{yc_id} of #{ysbook_id}" }
    "<p>$$$</p>"
  end

  def save_data_to_disk(data : String, type : String, ext : String) : Nil
    dir_path = self.tmp_path(type)
    Dir.mkdir_p(dir_path)

    file_path = File.join(dir_path, filename(ext))
    File.write(file_path, data)

    zip_path = self.zip_path(type)
    YsUtil.zip_data(zip_path, dir_path)

    Log.debug { "save #{file_path} to #{zip_path}" }
  end

  def set_tags(ztags : Array(String), force : Bool = false)
    return unless force || self.ztags.empty?

    self.ztags = ztags
    self.fix_vtags!(ztags) unless ztags.empty?
  end

  def set_text(ztext : String, force : Bool = false)
    return if ztext == "请登录查看评论内容" || ztext.blank?
    ztext = ztext.tr("\u0000", "\n").lines.map(&.strip).reject(&.empty?).join('\n')

    self.ztext = ztext
    self.fix_vhtml(ztext) if force || self.vhtml.empty?
  end

  def fix_vtags!(ztags = self.ztags)
    input = ztags.join('\n')
    return if input.blank?

    return unless output = TranUtil.qtran(input, wn_id: -2, format: "txt")
    self.vtags = output.split('\n', remove_empty: true)
  end

  def set_book_id(ysbook_id : Int32, force : Bool = false)
    self.ysbook_id = ysbook_id
    return unless force || self.nvinfo_id == 0
    self.nvinfo_id = Ysbook.get_wn_id(ysbook_id)
  end

  def set_list_id(yslist : Yslist)
    self.yslist_id = yslist.id
    self.yl_id = yslist.yl_id
  end

  def set_repl_total(value : Int32)
    self.repl_total = value if value > self.repl_total
  end

  def set_like_count(value : Int32)
    self.like_count = value if value > self.like_count
  end

  ###################

  def self.load(yc_id : String)
    load(yc_id.hexbytes)
  end

  def self.load(yc_id : Bytes)
    find({yc_id: yc_id}) || new({yc_id: yc_id}).tap(&.save!)
  end

  def self.get_id(yc_id : Bytes)
    PG_DB.query_one("select id from yscrits where yc_id = $1", yc_id, as: Int32)
  end

  ####

  def self.bulk_upsert(raw_crits : Array(RawYscrit), save_text : Bool = true)
    raw_crits.map do |raw_crit|
      out_crit = self.load(raw_crit.yc_id)

      out_crit.set_book_id(raw_crit.book.id)
      out_crit.ysuser_id = raw_crit.user.id

      out_crit.stars = raw_crit.stars
      out_crit.set_tags(raw_crit.tags, force: false)
      out_crit.set_text(raw_crit.ztext) if save_text

      out_crit.set_like_count(raw_crit.like_count)
      out_crit.set_repl_total(raw_crit.repl_total)

      out_crit.created_at = raw_crit.created_at
      out_crit.updated_at = raw_crit.updated_at || raw_crit.created_at

      out_crit.utime = out_crit.updated_at.to_unix
      out_crit.save!

      out_crit
    end
  end

  ####

  def self.update_repl_total(yc_id : Bytes, total : Int32, rtime : Int64)
    PG_DB.exec <<-SQL, total, rtime, yc_id
      update yscrits
      set repl_total = $1, repl_rtime = $2
      where yc_id = $3 and repl_total < $1
      SQL
  end
end
