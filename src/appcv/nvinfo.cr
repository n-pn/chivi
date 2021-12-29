require "./nvinfo/nv_seed"
require "./nvinfo/b_genre"

class CV::Nvinfo
  include Clear::Model

  self.table = "nvinfos"
  primary_key

  belongs_to author : Author
  has_many zhbooks : Zhbook, foreign_key: "nvinfo_id"
  has_many yscrits : Yscrit, foreign_key: "nvinfo_id"
  # has_many yslists : Yslist, through: "yscrits"

  column subdue_id : Int64? = nil # in case of duplicate entries, this column will point to the better one

  column zseed_ids : Array(Int32) = [] of Int32
  getter zseeds : Array(String) { NvSeed.to_s(zseed_ids) }

  column genre_ids : Array(Int32) = [] of Int32
  getter genres : Array(String) { BGenre.to_s(genre_ids) }

  column labels : Array(String) = [] of String

  column bhash : String # unique string generate from zh_title & zh_author
  column bslug : String # unique string generate from hv_title & bhash

  column zname : String # chinese title
  column hname : String # hanviet title
  column vname : String # localization

  column hslug : String # for text searching, auto generated from hname
  column vslug : String # for text searching, auto generated from vname

  column cover : String = ""
  column intro : String = "" # translated book description

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

  column total_clicks : Int32 = 0 # views count
  column dtopic_count : Int32 = 0 # discuss topic count
  column ubmemo_count : Int32 = 0 # user tracking count

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
      scrub = NvUtil.scrub_zname(input)
      where("zname LIKE '%#{scrub}%'")
    else
      scrub = NvUtil.scrub_vname(input, "-")
      where("(vslug LIKE '%-#{scrub}-%' OR hslug LIKE '%-#{scrub}-%')")
    end
  end

  scope :filter_author do |input|
    if input.nil?
      return self
    elsif input =~ /\p{Han}/
      scrub = NvUtil.scrub_zname(input)
      query = "zname LIKE '%#{scrub}%'"
    else
      scrub = NvUtil.scrub_vname(input, "-")
      query = "vslug LIKE '%-#{scrub}-%'"
    end

    where("author_id IN (SELECT id from authors WHERE #{query})")
  end

  scope :filter_zseed do |input|
    input ? where("zseed_ids @> ?", [NvSeed.map_id(input)]) : self
  end

  scope :filter_genre do |input|
    input ? where("genre_ids @> ?", [BGenre.map_id(input)]) : self
  end

  scope :filter_labels do |input|
    input ? where("labels @> ?", input) : self
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

  def add_nvseed(zseed : Int32) : Nil
    return if self.zseed_ids.includes?(zseed)
    self.zseed_ids.push(zseed).sort!
    self.zseed_ids_column.dirty!
  end

  def set_genres(genres : Array(String), force = false) : Nil
    return unless force || self.genre_ids.empty?
    genres_ids = BGenre.map_id(genres)

    self.genre_ids = genres_ids.empty? ? [0] : genres_ids
    self.genre_ids_column.dirty!
  end

  def set_zintro(lines : Array(String), force = false) : Nil
    return unless force || self.intro.empty?
    cvmtl = MtCore.generic_mtl(bhash)
    self.intro = lines.map { |line| cvmtl.cv_plain(line).to_s }.join("\n")
  end

  def set_bcover(cover : String, force = false) : Nil
    self.cover = cover if force || self.cover.empty?
  end

  def set_utime(utime : Int64, force = false) : Int64?
    return unless force || utime > self.utime
    self.atime = utime if self.atime < utime
    self.utime = utime
  end

  def update_utime(utime : Int64) : Nil
    self.save! if set_utime(utime)
  end

  def bump!(time = Time.utc)
    update!(atime: time.to_unix)
  end

  def set_status(status : Int32, force = false) : Nil
    return unless force || self.status < status || self.status == 3 && status > 0
    self.status = status
  end

  def set_shield(shield : Int32, force = false) : Nil
    self.shield = shield if force || shield > self.shield
  end

  def set_ys_scores(voters : Int32, rating : Int32) : Nil
    self.ys_voters = voters
    self.ys_scores = voters * rating
    fix_scores!
  end

  # trigger when user add a new book review
  def add_cv_rating(rating : Int32) : Nil
    self.cv_voters += 1
    self.cv_scores += rating
    fix_scores!
  end

  # trigger when user change book rating in his review
  def fix_cv_rating(new_rating : Int32, old_rating : Int32) : Nil
    return if new_rating == old_rating
    self.cv_scores = self.cv_scores - old_rating + new_rating
    fix_scores!
  end

  # recalculate
  def fix_scores! : Nil
    self.voters = self.cv_voters + self.ys_voters
    scores = self.cv_scores + self.ys_scores

    if self.voters < 30
      scores += (30 - self.voters) * 45
      self.rating = scores // 30
    else
      self.rating = scores // self.voters
    end

    self.weight = scores + Math.log(self.total_clicks + 10).to_i
  end

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

  def self.load!(bhash : String)
    CACHE_STR.get(bhash) do
      find!({bhash: bhash}).tap { |x| CACHE_INT.set(x.id, x) }
    end
  end

  def self.upsert!(author : Author, zname : String)
    get(author, zname) || begin
      bhash = UkeyUtil.digest32("#{zname}--#{author.zname}")
      nvinfo = new({author_id: author.id, bhash: bhash, zname: zname})

      nvinfo.vname = NvUtil.btitle_vname(zname, bhash)
      nvinfo.vslug = "-" + NvUtil.scrub_vname(nvinfo.vname, "-") + "-"

      nvinfo.hname = NvUtil.hanviet(zname)
      hslug = NvUtil.scrub_vname(nvinfo.hname, "-")
      nvinfo.hslug = "-" + hslug + "-"

      nvinfo.bslug = hslug.split("-").first(8).join("-") + bhash[0..3]

      nvinfo.tap(&.save!)
    end
  end
end
