require "./_util"

require "./ys_list"
require "./ys_book"
require "./ys_user"

require "../_raw/raw_ys_crit"

class YS::Yscrit
  include Clear::Model
  self.table = "yscrits"

  primary_key
  column origin_id : String = ""

  column nvinfo_id : Int32 = 0
  column ysbook_id : Int32 = 0

  column ysuser_id : Int32 = 0
  column yslist_id : Int32 = 0

  column y_uid : Int32 = 0
  column y_lid : String = ""

  column stars : Int32 = 3  # voting 1 2 3 4 5 stars
  column b_len : Int32 = -1 # body size (real data is stored in a different location)

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

  getter ztext : String { load_ztext_from_disk }
  getter vhtml : String { load_vhtml_from_disk }

  ZIP_DIR = "var/ysapp/crits-zip"
  TXT_DIR = "var/ysapp/crits-txt"

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
    # return "$$$" if self.b_len == 0
    YsUtil.read_zip(self.zip_path("zh"), filename("txt")) { "$$$" }
  end

  def load_vhtml_from_disk : String
    load_htm_from_disk("vi", persist: true) do |ztext|
      TranUtil.qtran(ztext, self.nvinfo_id, "txt")
    end
  end

  def load_btran_from_disk : String
    load_htm_from_disk("bv", persist: true) { |ztext| TranUtil.btran(ztext) }
  end

  def load_deepl_from_disk : String
    load_htm_from_disk("de", persist: true) { |ztext| TranUtil.deepl(ztext) }
  end

  private def load_htm_from_disk(type : String, persist : Bool = true, &)
    YsUtil.read_zip(self.zip_path(type), filename("htm")) do
      ztext = self.load_ztext_from_disk

      if ztext != "$$$" && (vtext = yield ztext)
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
    Log.error(exception: err) { "error loading #{type} html for #{origin_id} of #{ysbook_id}" }
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
    self.fix_vtags!(ztags)
  end

  def fix_vtags!(ztags = self.ztags)
    input = ztags.join('\n')
    return if input.blank?

    return unless output = TranUtil.qtran(input, wn_id: -2, format: "txt")
    self.vtags = output.split('\n', remove_empty: true)
  end

  # def fix_vhtml(ztext : String, dname = self.nvinfo.dname)
  #   self.vhtml = CV::BookUtil.cv_lines(ztext, dname, mode: :html)
  # end

  ###################

  def self.gen_id(origin_id : String)
    origin_id[12..].to_i64(base: 16)
  end

  def self.load(y_cid : String)
    find({origin_id: y_cid}) || new({id: gen_id(y_cid), origin_id: y_cid})
  end

  ####

  def self.bulk_upsert(raw_crits : Array(RawYsCrit), save_text : Bool = true)
    raw_crits.each do |raw_crit|
      out_crit = self.load(raw_crit.y_cid)
      out_book = Ysbook.load(raw_crit.book.id)
      out_user = Ysuser.load(raw_crit.user.id)

      out_crit.ysbook_id = out_book.id
      out_crit.nvinfo_id = out_book.nvinfo_id

      out_crit.y_uid = out_user.y_uid
      out_crit.ysuser_id = out_user.id # TODO: remove this

      out_crit.stars = raw_crit.stars
      out_crit.set_tags(raw_crit.tags, force: true)

      if save_text && raw_crit.ztext != "请登录查看评论内容"
        out_crit.b_len = raw_crit.ztext.size
        out_crit.save_data_to_disk(raw_crit.ztext, type: "zh", ext: "txt")
      end

      out_crit.like_count = raw_crit.like_count
      out_crit.repl_total = raw_crit.repl_total

      out_crit.created_at = raw_crit.created_at
      out_crit.updated_at = raw_crit.updated_at || raw_crit.created_at

      out_crit.utime = out_crit.updated_at.to_unix
      out_crit.save!
    end
  end
end
