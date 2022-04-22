class CV::Yscrit
  include Clear::Model
  self.table = "yscrits"

  primary_key
  column origin_id : String = ""

  belongs_to nvinfo : Nvinfo
  belongs_to ysbook : Ysbook
  belongs_to ysuser : Ysuser
  belongs_to yslist : Yslist?

  column stars : Int32 = 3 # voting 1 2 3 4 5 stars
  column _sort : Int32 = 0

  column ztext : String = "" # orginal comment
  column vhtml : String = "" # translated comment

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

  scope :sort_by do |order|
    case order
    when "ctime" then self.order_by(id: :desc)
    when "likes" then self.order_by(like_count: :desc)
    when "score" then self.order_by(_sort: :desc, stars: :desc)
    when "stars" then self.order_by(stars: :desc, like_count: :desc)
    else              self.order_by(created_at: :desc)
    end
  end

  getter zhtext : Array(String) do
    self.ztext.split("\n").map(&.strip).reject(&.empty?)
  end

  def update_sort!
    self._sort = self.stars * self.stars * self.like_count
  end

  def set_tags(tags : Array(String))
    return if tags.empty?

    self.ztags = tags
    self.vtags = tags.map { |x| MtCore.cv_hanviet(x) }
  end

  def set_body(ztext : String, dname = self.nvinfo.dname)
    return if ztext.empty? || ztext == "请登录查看评论内容"
    self.ztext = ztext
    self.vhtml = cvdata(dname, mode: :html)
  end

  enum RenderMode
    Mtl; Text; Html
  end

  def cvdata(dname = self.nvinfo.dname, mode : RenderMode = :mtl)
    cvmtl = MtCore.generic_mtl(dname)

    zhtext.map do |line|
      mt_list = cvmtl.cv_plain(line)

      case mode
      when .text? then mt_list.to_s
      when .html? then "<p>#{mt_list}</p>"
      else             mt_list.to_str
      end
    end.join("\n")
  end

  ###################

  def self.get!(id : Int64, created_at : Time)
    find({id: id}) || new({id: id, created_at: created_at})
  end
end
