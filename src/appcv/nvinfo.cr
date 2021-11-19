class CV::Nvinfo
  include Clear::Model

  self.table = "nvinfos"
  primary_key

  column succeed_id : Int64? = nil # in case of duplicate entries, this column will point to the better one

  belongs_to author : Author

  has_many zhbooks : Zhbook, foreign_key: "nvinfo_id"
  has_many yscrits : Yscrit, foreign_key: "nvinfo_id"
  has_many yslists : Yslist, through: "yscrits"

  column nvseed_ids : Array(Int32) = [] of Int32
  getter nvseeds : Array(String) { Chseed.to_s(nvseed_ids) }

  column bgenre_ids : Array(Int32) = [] of Int32
  getter bgenres : Array(String) { Bgenre.to_s(bgenre_ids) }

  column blabels : Array(String) = [] of String

  column bhash : String # unique string generate from zh_title & zh_author
  column bslug : String # unique string generate from hv_title & bhash

  column ztitle : String # chinese title
  column htitle : String # hanviet title
  column vtitle : String # localization

  column htslug : String # for text searching, auto generated from hname
  column vtslug : String # for text searching, auto generated from vname

  column bcover : String = ""
  column bintro : String = "" # translated book desc

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
  column utime : Int64 = 0 # value by minute from the epoch, max value of nvseed mftime and ys_mftime

  column clicks : Int32 = 0 # views count
  column weight : Int32 = 0 # voters * rating + ???

  column voters : Int32 = 0 # = ys_voters + vi_voters * 2 + random_seed (if < 25)
  column rating : Int32 = 0 # delivered from above values

  column dtopics : Int32 = 0 # discuss topic count
  column ubmemos : Int32 = 0 # user tracking count

  column cv_voters : Int32 = 0 # unique revierwers
  column cv_rating : Int32 = 0 # average rating

  column cv_crits : Int32 = 0 # chivi book review count
  column cv_lists : Int32 = 0 # chivi booi list count

  column cv_chaps : Int32 = 0 # official chapters count
  column cv_utime : Int64 = 0 # offiial chapter source updates

  column ys_snvid : Int64? = nil  # yousuu book id
  column ys_utime : Int64 = 0_i64 # yousuu book update time

  column ys_voters : Int32 = 0 # yousuu book voters
  column ys_rating : Int32 = 0 # yousu book average ratings

  column ys_crits : Int32 = 0 # yousuu review counts
  column ys_lists : Int32 = 0 # yousuu book list count
  column ys_words : Int32 = 0 # original word count

  column orig_link : String = "" # original publisher novel page
  column orig_name : String = "" # original publisher name, extract from link

  timestamps # created_at and updated_at

  scope :filter_ztitle do |input|
    input ? where("ztitle LIKE %?%", input) : self
  end

  scope :filter_vtitle do |input|
    input ? where("vtslug LIKE %?% OR htslug LIKE %?%", input, input) : self
    # where("vtitle LIKE %$% OR htitle LIKE %$%", frag, frag) if accent
  end

  scope :filter_btitle do |input|
    if input.nil?
      self
    elsif input =~ /\p{Han}/
      scrub = BookUtils.scrub_zname(input)
      where("ztitle LIKE '%#{scrub}%'")
    else
      scrub = BookUtils.scrub_vname(input, "-")
      where("vtslug LIKE '%-#{scrub}-%' OR htslug LIKE '%-#{scrub}-%'")
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

  scope :filter_nseed do |input|
    input ? where("nvseed_ids @> ?", [Chseed.index(input)]) : self
  end

  scope :filter_genre do |input|
    input ? where("bgenre_ids @> ?", [Bgenre.map_id(input)]) : self
  end

  scope :filter_label do |input|
    input ? where("blabels @> ?", input) : self
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

  def add_zhseed(nseed : Int32) : Nil
    return if self.nvseed_ids.includes?(nseed)
    self.nvseed_ids.push(nseed).sort!
    self.nvseed_ids_column.dirty!
  end

  def set_genres(genres : Array(String), force = false) : Nil
    return unless force || self.bgenre_ids.empty?
    genres_ids = Bgenre.map_zh(genres)

    self.bgenre_ids = genres_ids.empty? ? [0] : genres_ids
    self.bgenre_ids_column.dirty!
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

  def self.get(author : Author, ztitle : String)
    find({author_id: author.id, ztitle: ztitle})
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

  # def self.upsert!(author : Author, ztitle : String,
  #                  htitle : String? = nil, vtitle : String? = nil)
  #   get(author, ztitle) || begin
  #     bhash = UkeyUtil.digest32("#{ztitle}--#{author.zname}")
  #     vtitle ||= BookUtils.get_vi_btitle(ztitle, bhash)
  #     vtslug = "-#{BookUtils.scrub_vname(vtitle, "-")}-"

  #     htitle ||= BookUtils.hanviet(ztitle)
  #     htslug = BookUtils.scrub_vname(htitle, "-")

  #     bslug = htslug.split("-").first(8).push(bhash[0..3]).join("-")

  #     htslug = "-#{htslug}-"
  #     cvbook = new({
  #       author_id: author.id, bhash: bhash, bslug: bslug,
  #       ztitle: ztitle, htitle: htitle, vtitle: vtitle,
  #       htslug: htslug, vtslug: vtslug,
  #     })

  #     cvbook.tap(&.save!)
  #   end
  # end
end
