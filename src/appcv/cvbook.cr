class CV::Cvbook
  include Clear::Model

  self.table = "cvbooks"
  primary_key

  has_many ysbooks : Ysbook, foreign_key: "cvbook_id"
  has_many zhbooks : Zhbook, foreign_key: "cvbook_id"
  has_many yscrits : Yscrit, foreign_key: "cvbook_id"
  has_many yslists : Yslist, through: "yscrits"

  belongs_to author : Author

  column bgenre_ids : Array(Int32) = [0]
  column zhseed_ids : Array(Int32) = [0]

  column bhash : String # unique string generate from zh_title & zh_author
  column bslug : String # unique string generate from hv_title & bhash

  column ztitle : String # chinese title
  column htitle : String # hanviet title
  column vtitle : String # localization
  column htslug : String # for text searching, auto generated from hname
  column vtslug : String # for text searching, auto generated from vname

  getter bgenres : Array(String) { Bgenre.all(bgenre_ids) }
  getter zhseeds : Array(String) { Zhseed.all(zhseed_ids) }

  column bcover : String = ""
  column bintro : String = ""

  # 0: ongoing, 2: completed, 3: axed/hiatus, 4: unknown
  column status : Int32 = 0

  # 0: public (anyone can see), 1: protected (show to registered users),
  # 2: private (show to power users), 3: hidden (show to administrators only)
  column shield : Int32 = 0 # default to 0

  column bumped : Int64 = 0 # value by minute from the epoch, update whenever an registered user viewing book info
  column mftime : Int64 = 0 # value by minute from the epoch, max value of nvseed mftime and ys_mftime

  column weight : Int32 = 0 # voters * rating + ???
  column voters : Int32 = 0 # = ys_voters + vi_voters * 2 + random_seed (if < 25)
  column rating : Int32 = 0 # delivered from above values

  column cv_voters : Int32 = 0
  column cv_rating : Int32 = 0
  column cv_clicks : Int32 = 0

  column chap_count : Int32 = 0
  column list_count : Int32 = 0
  column crit_count : Int32 = 0

  getter vi_title : String { vtitle.empty? ? htitle : vtitle }

  def set_genres(genres : Array(String), force = false)
    return unless force || self.bgenre_ids == [0]
    genres_ids = Bgenre.zh_map_ids(genres)

    self.bgenre_ids = genres_ids.empty? ? [0] : genres_ids
  end

  def set_mftime(mftime : Int64, force = false) : Nil
    return unless force || mftime > self.mftime
    self.mftime = mftime
    self.bumped = mftime
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

  def set_zintro(zintro : String, force = false) : Nil
    return unless force || self.bintro.empty?
    self.bintro = BookUtils.convert(zintro, self.bhash).join
  end

  def add_zhseed(zseed : Int32) : Nil
    return if self.zhseed_ids.includes?(zseed)
    self.zhseed_ids.push(zseed)
  end

  def set_scores(voters : Int32, rating : Int32) : Nil
    self.voters = voters
    self.rating = rating
    self.weight = voters * rating
    return if voters >= 25

    self.weight += (25 - voters) * Random.rand(40..60)
    self.rating = self.weight // 25
  end

  def bump!(time = Time.utc)
    update!(bumped: time.to_unix)
  end

  class_getter total : Int64 { query.count }

  def self.get(author : Author, ztitle : String)
    find({author_id: author.id, ztitle: ztitle})
  end

  def self.upsert!(author : Author, ztitle : String,
                   htitle : String? = nil, vtitle : String? = nil)
    get(author, ztitle) || begin
      htitle ||= BookUtils.hanviet(ztitle)
      vtitle ||= BookUtils.get_vi_btitle(ztitle)

      htslug = BookUtils.scrub_vname(htitle, "-")
      vtslug = BookUtils.scrub_vname(vtitle, "-")

      bhash = CoreUtils.digest32("#{ztitle}--#{author.zname}")
      bslug = htslug.split("-").first(7).push(bhash[0..3]).join("-")

      cvbook = new({
        author_id: author.id, bhash: bhash, bslug: bslug,
        ztitle: ztitle, htitle: htitle, vtitle: vtitle,
        htslug: htslug, vtslug: vtslug,
      })

      cvbook.tap(&.save!)
    end
  end

  def self.filter_btitle(query, frag : String?)
    return query unless frag
    frag =~ /\p{Han}/ ? filter_ztitle(query, frag) : filter_vtitle(query, frag)
  end

  def self.filter_ztitle(query, frag : String)
    query.where("ztitle LIKE %$%", BookUtils.scrub_zname(frag))
  end

  def self.filter_vtitle(query, frag : String, accent = false)
    scrub = BookUtils.scrub_vname(frag)
    query = query.where("vtslug LIKE %$% OR htslug LIKE %$%", scrub, scrub)
    accent ? query.where("vtitle LIKE %$% OR htitle LIKE %$%", frag, frag) : query
  end

  def self.filter_author(query, author : String?, accent = false)
    return query unless author
    # author_query = author =~ /\p{Han}/ ? Author.glob_zh(author) : Author.glob_vi(author, accent: accent)

    author_ids = Author.glob(author).map(&.id.not_nil!)
    query.where { cvbooks.author_id.in?(author_ids) }
  end

  def self.filter_genre(query, genre : String?)
    return query unless genre
    genre_id = Bgenre.map_id(genre)
    query.where("bgenre_ids @> ?", [genre_id])
  end

  def self.filter_zseed(query, sname : String?)
    return query unless sname
    zseed = Zhseed.index(sname)
    query.where("chseed_ids @> ?", [zseed])
  end

  def self.order_by(query, order : String? = "access")
    case order
    when "weight" then query.order_by(weight: :desc)
    when "rating" then query.order_by(rating: :desc)
    when "voters" then query.order_by(voters: :desc)
    when "update" then query.order_by(mftime: :desc)
    else               query.order_by(bumped: :desc)
    end
  end
end
