require "./nvinfo/*"
require "./shared/*"

class CV::Nvinfo
  include Clear::Model

  self.table = "nvinfos"
  primary_key

  getter dt_ii : Int32 { (id > 0 ? id + 20 : id * -5).to_i &* 10000 }

  belongs_to author : Author
  has_many zhbooks : Zhbook, foreign_key: "nvinfo_id"
  has_many yscrits : Yscrit, foreign_key: "nvinfo_id"
  has_many dtopics : Dtopic, foreign_key: "nvinfo_id"
  # has_many yslists : Yslist, through: "yscrits"

  column subdue_id : Int64 = 0 # in case of duplicate entries, this column will point to the better one

  column zseed_ids : Array(Int32) = [] of Int32
  getter snames : Array(String) { SnameMap.map_str(zseed_ids) }

  column genre_ids : Array(Int32) = [] of Int32
  getter genres : Array(String) { GenreMap.to_s(genre_ids) }

  column labels : Array(String) = [] of String

  column bhash : String # unique string generate from zh_title & zh_author
  column bslug : String # unique string generate from hv_title & bhash

  getter dname : String { "-" + bhash }

  column zname : String # chinese title
  column hname : String # hanviet title
  column vname : String # localization

  column hslug : String # for text searching, auto generated from hname
  column vslug : String # for text searching, auto generated from vname

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
  column utime : Int64 = 0 # value by minute from the epoch, max value of zhbook utime and ys_utime

  column cv_utime : Int64 = 0_i64 # official chapter source updates
  column ys_utime : Int64 = 0_i64 # yousuu book update time

  # ranking

  column weight : Int32 = 0 # voters * rating + ???
  column rating : Int32 = 0 # delivered from above values
  column voters : Int32 = 0 # = ys_voters + vi_voters * 2 + random_seed (if < 25)

  column cv_voters : Int32 = 0 # unique revierwers
  column ys_voters : Int32 = 0 # yousuu book voters

  column cv_scores : Int32 = 0 # chivi users ratings * voters
  column ys_scores : Int32 = 0 # yousuu users ratings * voters

  # counters

  column cv_chap_count : Int32 = 0 # official chapters count
  column ys_word_count : Int32 = 0 # total words count from yousuu

  column cvcrit_count : Int32 = 0 # chivi reviews count
  column yscrit_count : Int32 = 0 # yousuu reviews count

  column cvlist_count : Int32 = 0 # chivi booklists count
  column yslist_count : Int32 = 0 # yousuu booklists count

  column total_clicks : Int32 = 0 # chap views count
  column dtopic_count : Int32 = 0 # discuss topic count
  column ubmemo_count : Int32 = 0 # user tracking count

  column dt_view_count : Int32 = 0
  column dt_post_utime : Int64 = 0
  # links

  column ys_snvid : Int64? = nil # yousuu book id
  column pub_name : String = ""  # original publisher name, extract from link
  column pub_link : String = ""  # original publisher novel page

  timestamps # created_at and updated_at

  scope :filter_zname do |input|
    input ? where("zname LIKE %?%", input) : self
  end

  scope :filter_vname do |input|
    input ? where("vslug LIKE %?% OR hslug LIKE %?%", input, input) : self
    # where("vname LIKE %$% OR hname LIKE %$%", frag, frag) if accent
  end

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

  scope :filter_zseed do |input|
    input ? where("zseed_ids @> ?", [SnameMap.map_int(input)]) : self
  end

  scope :filter_genre do |input|
    input ? where("genre_ids @> ?", GenreMap.map_id(input.split('+'))) : self
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

  def self.upsert!(author : Author, zname : String, remap = false)
    unless nvinfo = get(author, zname)
      bhash = UkeyUtil.digest32("#{zname}--#{author.zname}")
      nvinfo = new({author_id: author.id, bhash: bhash, zname: zname})
      remap = true
    end

    nvinfo.tap { |x| x.fix_names! if remap }
  end
end
