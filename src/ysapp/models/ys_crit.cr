require "./_util"

require "./ys_list"

class YS::Yscrit
  include Clear::Model
  self.table = "yscrits"

  primary_key
  column origin_id : String = ""

  column nvinfo_id : Int32 = 0
  column ysbook_id : Int32 = 0

  belongs_to ysuser : Ysuser
  belongs_to yslist : Yslist?

  column stars : Int32 = 3 # voting 1 2 3 4 5 stars
  column _sort : Int32 = 0

  column ztags : Array(String) = [] of String
  column vtags : Array(String) = [] of String

  column utime : Int64 = 0 # list changed at by seconds from epoch
  column stime : Int64 = 0 # list checked at by minutes from epoch

  column repl_total : Int32 = 0
  column repl_count : Int32 = 0
  column like_count : Int32 = 0

  timestamps

  scope :filter_nvinfo do |nvinfo_id|
    nvinfo_id ? where("nvinfo_id = #{nvinfo_id}") : self
  end

  scope :filter_ysuser do |ysuser_id|
    ysuser_id ? where("ysuser_id = #{ysuser_id}") : self
  end

  scope :filter_yslist do |yslist_id|
    yslist_id ? where("yslist_id = #{yslist_id}") : self
  end

  scope :filter_labels do |vtag|
    vtag ? where("vtags @> ?", [vtag]) : self
  end

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

  def vdict
    YsUtil.vdict(self.nvinfo_id)
  end

  def zip_path(type = "zh")
    "var/ysapp/crits/#{self.ysbook_id}-#{type}.zip"
  end

  def tmp_path(type = "zh")
    "var/ysapp/crits.tmp/#{self.ysbook_id}-#{type}"
  end

  def filename(type = "zh", ext = "txt")
    "#{self.origin_id}.#{ext}"
  end

  def load_ztext_from_disk : String
    YsUtil.read_zip(self.zip_path("zh"), filename("zh", "txt")) { "$$$" }
  rescue err
    Log.error(exception: err) { err.message }
    "$$$"
  end

  def load_vhtml_from_disk : String
    load_html_from_disk("vi", persist: true) { |ztext| TranUtil.qtran(ztext, vdict.dname) }
  end

  def load_btran_from_disk : String
    load_html_from_disk("bv", persist: true) { |ztext| TranUtil.btran(ztext) }
  end

  def load_deepl_from_disk : String
    load_html_from_disk("de", persist: true) { |ztext| TranUtil.deepl(ztext) }
  end

  private def load_html_from_disk(type : String, persist : Bool = true)
    YsUtil.read_zip(self.zip_path(type), filename(type, "htm")) do
      ztext = self.ztext

      if (!ztext.empty?) && (tranlation = yield ztext)
        html = tranlation.split('\n').map { |x| "<p>#{x}</p>" }.join('\n')
      else
        html = "<p>$$$</p>"
        persist = ztext.empty?
      end

      save_file_to_disk(html, type, ext: "htm") if persist
      html
    end
  rescue err
    Log.error(exception: err) { "error loading #{type} html for #{origin_id} of #{ysbook_id}" }
    "<p>$$$</p>"
  end

  private def save_file_to_disk(content : String, type : String, ext : String)
    dir_path = self.tmp_path(type)
    Dir.mkdir_p(dir_path)

    file_path = File.join(dir_path, filename(type, ext))
    File.write(file_path, content)

    Log.debug { "save #{file_path} to #{self.zip_path(type)}" }
    YsUtil.zipping(self.zip_path(type), dir_path)
  end

  #############

  def fix_sort!
    self._sort = self.stars &* (self.stars &* self.like_count &+ self.repl_count)
  end

  def set_tags(ztags : Array(String), force : Bool = false)
    return unless force || self.ztags.empty?
    self.ztags = ztags
    self.fix_vtags!(ztags)
  end

  def fix_vtags!(ztags = self.ztags)
    self.vtags = TranUtil.qtran(ztags, "!labels").split('\n')
  end

  # def fix_vhtml(ztext : String, dname = self.nvinfo.dname)
  #   self.vhtml = CV::BookUtil.cv_lines(ztext, dname, mode: :html)
  # end

  ###################

  def self.gen_id(origin_id : String)
    origin_id[12..].to_i64(base: 16)
  end

  def self.upsert!(origin_id : String, created_at : Time)
    find({origin_id: origin_id}) || begin
      new({id: gen_id(origin_id), origin_id: origin_id, created_at: created_at})
    end
  end
end
