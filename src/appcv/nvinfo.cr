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
  column pub_link : String = ""  # original publisher novel page
  column pub_name : String = ""  # original publisher name, extract from link

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
      scrub = BookUtils.scrub_zname(input)
      where("zname LIKE '%#{scrub}%'")
    else
      scrub = BookUtils.scrub_vname(input, "-")
      where("vslug LIKE '%-#{scrub}-%' OR hslug LIKE '%-#{scrub}-%'")
    end
  end

  scope :filter_author do |input|
    if input.nil?
      return self
    elsif input =~ /\p{Han}/
      scrub = BookUtils.scrub_zname(input)
      query = "zname LIKE '%#{scrub}%'"
    else
      scrub = BookUtils.scrub_vname(input, "-")
      query = "vslug LIKE '%-#{scrub}-%'"
    end

    where("author_id IN (SELECT id from authors WHERE #{query})")
  end

  scope :filter_zseed do |input|
    input ? where("zseed_ids @> ?", [Nvseed.map_id(input)]) : self
  end

  scope :filter_genre do |input|
    input ? where("genre_ids @> ?", [Bgenre.map_id(input)]) : self
  end

  scope :filter_labels do |input|
    input ? where("labels @> ?", input) : self
  end

  scope :sort_by do |order|
    case order
    when "weight" then order_by(weight: :desc)
    when "rating" then order_by(rating: :desc)
    when "voters" then order_by(voters: :desc)
    when "update" then order_by(mtime: :desc)
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
    genres_ids = Bgenre.map_zh(genres)

    self.genre_ids = genres_ids.empty? ? [0] : genres_ids
    self.genre_ids_column.dirty!
  end

  def set_utime(utime : Int64, force = false) : Nil
    return unless force || utime > self.utime
    self.utime = utime
    self.atime = utime if self.atime < utime
  end

  def bump!(time = Time.utc)
    update!(atime: time.to_unix)
  end

  def set_status(status : Int32, force = false) : Nil
    self.status = status if force || status > self.status
  end

  def set_shield(shield : Int32, force = false) : Nil
    self.shield = shield if force || shield > self.shield
  end

  def set_bcover(bcover : String, force = false) : Nil
    self.bcover = bcover if force || self.bcover.empty?
  end

  def set_ys_scores(voters : Int32, rating : Int32) : Nil
    self.ys_voters = voters
    self.ys_rating = rating
    fix_scores!
  end

  # trigger when user add a new book review
  def add_cv_rating(rating : Int32) : Nil
    points = self.cv_voters * self.cv_rating + rating

    self.cv_voters += 1
    self.cv_rating = points // self.cv_voters
    fix_scores!
  end

  # trigger when user change book rating in his review
  def fix_cv_rating(new_rating : Int32, old_rating : Int32) : Nil
    return if new_rating == old_rating

    points = self.cv_voters * self.cv_rating + new_rating - old_rating
    self.cv_rating = points // self.cv_voters
    fix_scores!
  end

  # recalculate
  def fix_scores! : Nil
    points = self.cv_voters * self.cv_rating + self.ys_voters * self.ys_rating
    self.voters = self.cv_voters + self.ys_voters

    if self.voters < 25
      points += (25 - self.voters) * 50
      self.rating = points // 25
    else
      self.rating = points // self.voters
    end

    self.weight = points + Math.log(self.clicks).to_i * 10 + Math.log(self.utime // 60).to_i
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

  def self.upsert!(author : String, zname : String, fixed = true)
    unless fixed
    end

    get(author, zname) || begin
      bhash = UkeyUtil.digest32("#{zname}--#{author.zname}")

      vname = BookUtils.get_vi_btitle(zname, bhash)
      vslug = "-#{BookUtils.scrub_vname(vname, "-")}-"

      hname = BookUtils.hanviet(zname)
      hslug = BookUtils.scrub_vname(hname, "-")

      bslug = hslug.split("-").first(8).push(bhash[0..3]).join("-")

      hslug = "-#{hslug}-"
      cvbook = new({
        author_id: author.id, bhash: bhash, bslug: bslug,
        zname: zname, hname: hname, vname: vname,
        hslug: hslug, vslug: vslug,
      })

      cvbook.tap(&.save!)
    end
  end
end
