require "./nvinfo/*"
require "./shared/*"

class CV::Nvinfo
  include Clear::Model

  self.table = "nvinfos"
  primary_key

  getter dt_ii : Int32 { (id > 0 ? id &+ 20 : id * -5).to_i &* 10000 }

  belongs_to author : Author
  # belongs_to btitle : Btitle

  has_many nvseeds : Nvseed, foreign_key: "nvinfo_id"
  # has_many yscrits : Yscrit, foreign_key: "nvinfo_id"
  # has_many cvposts : Cvpost, foreign_key: "nvinfo_id"
  # has_many yslists : Yslist, through: "yscrits"

  column ysbook_id : Int64 = 0 # yousuu book id
  column subdue_id : Int64 = 0 # in case of duplicate entries, this column will point to the better one

  ##############

  column zname : String      # book chinese name
  column hname : String = "" # hanviet title
  column vname : String = "" # localization

  column hslug : String = "" # for text searching, auto generated from hname
  column vslug : String = "" # for text searching, auto generated from vname

  #################

  column bhash : String # unique string generate from zh_title & zh_author
  column bslug : String # unique string generate from hv_title & bhash

  getter dname : String { "-" + bhash }

  ###########

  column zseeds : Array(Int32) = [] of Int32
  getter snames : Array(String) { SnameMap.map_str(zseeds) }

  column igenres : Array(Int32) = [] of Int32
  getter vgenres : Array(String) { GenreMap.to_s(igenres) }

  column zlabels : Array(String) = [] of String
  column vlabels : Array(String) = [] of String

  ###########

  column scover : String = "" # original seed cover url
  column bcover : String = "" # cached book cover path

  column zintro : String = "" # book introduction in chinese
  column vintro : String = "" # translated book introduction

  # status value:
  # 0: ongoing,
  # 1: completed,
  # 2: axed/hiatus,
  # 3: unknown
  column status : Int32 = 0

  # shield value:
  # 0: public (anyone can see),
  # 1: protected (show to registered users),
  # 2: private (show to power users),
  # 3: hidden (show to administrators only)
  column shield : Int32 = 0 # default to 0

  column atime : Int64 = 0 # value by minute from the epoch, update whenever an registered user viewing book info
  column utime : Int64 = 0 # value by minute from the epoch, max value of nvseed utime and ys_utime

  # ranking

  column voters : Int32 = 0
  column weight : Int32 = 0
  column rating : Int32 = 0

  column chap_count : Int32 = 0 # chap views count
  column word_count : Int32 = 0 # chap views count

  column mark_count : Int32 = 0 # discuss topic count
  column view_count : Int32 = 0 # user tracking count

  column post_count : Int32 = 0
  column board_bump : Int64 = 0

  # origin, copy from yousuu

  column pub_name : String = "" # original publisher name, extract from link
  column pub_link : String = "" # original publisher novel page

  timestamps # created_at and updated_at

  scope :filter_btitle do |input|
    if input.nil?
      self
    elsif input =~ /\p{Han}/
      scrub = BookUtil.scrub_zname(input)
      where("zname LIKE '%#{scrub}%'")
    else
      scrub = BookUtil.scrub_vname(input, "-")
      where("(vslug LIKE '%-#{scrub}-%' OR hslug LIKE '%-#{scrub}-%')")
    end
  end

  scope :filter_author do |input|
    if input.nil?
      return self
    elsif input =~ /\p{Han}/
      scrub = BookUtil.scrub_zname(input)
      query = "zname LIKE '%#{scrub}%'"
    else
      scrub = BookUtil.scrub_vname(input, "-")
      query = "vslug LIKE '%-#{scrub}-%'"
    end

    where("author_id IN (SELECT id from authors WHERE #{query})")
  end

  scope :filter_zseeds do |input|
    input ? where("zseeds @> ?", [SnameMap.map_int(input)]) : self
  end

  scope :filter_genres do |input|
    input ? where("igenres @> ?", GenreMap.map_id(input.split('+'))) : self
  end

  scope :filter_labels do |input|
    input ? where("labels @> ?", input) : self
  end

  scope :filter_origin do |input|
    input ? where("pub_name = ?", input) : self
  end

  scope :filter_cvuser do |uname, bmark|
    if uname && (cvuser = Cvuser.load!(uname))
      where_clause = "cvuser_id=#{cvuser.id}"
      where_clause += " and status=#{Ubmemo.status(bmark)}" if bmark
      where("id IN (SELECT nvinfo_id from ubmemos where #{where_clause})")
    else
      self
    end
  end

  scope :sort_by do |order|
    case order
    when "weight" then order_by(weight: :desc)
    when "rating" then order_by(rating: :desc)
    when "voters" then order_by(voters: :desc)
    when "update" then order_by(utime: :desc)
    when "access" then order_by(atime: :desc)
    else               order_by(id: :desc)
    end
  end

  include NvinfoModel

  #########################################

  class_getter total : Int64 { query.count }

  def self.get(author : Author, zname : String)
    find({author_id: author.id, zname: zname})
  end

  CACHE_INT = RamCache(Int64, self).new
  CACHE_STR = RamCache(String, self).new

  def self.load!(id : Int64)
    CACHE_INT.get(id) { find!({id: id}) }
  end

  def self.load!(bname : String)
    CACHE_STR.get(bname) do
      item = find({bslug: bname}) || find({bhash: bname})
      raise "Book not found" unless item
      item.tap { |x| CACHE_INT.set(x.id, x) }
    end
  end

  def self.upsert!(author : Author, zname : String)
    unless nvinfo = get(author, zname)
      bhash = UkeyUtil.digest32("#{zname}--#{author.zname}")
      nvinfo = new({author_id: author.id, zname: zname, bhash: bhash})
      nvinfo.fix_title!
    end

    nvinfo
  end
end
