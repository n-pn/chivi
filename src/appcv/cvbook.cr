class CV::Cvbook < Granite::Base
  connection pg
  table cvbooks

  column id : Int64, primary: true
  timestamps

  has_many :ysbook
  has_many :zhbook
  has_many :yscrit
  has_many :yslist, through: :yscrit

  belongs_to :author
  column bgenre_ids : Array(Int32) = [0]
  column zhseed_ids : Array(Int32) = [0]

  column bhash : String # unique string generate from zh_title & zh_author
  column bslug : String # unique string generate from hv_title & bhash

  column ztitle : String # chinese title
  column htitle : String # hanviet title
  column vtitle : String # localization

  # for text searching
  column ztitle_ts : String # auto generated from zname
  column htitle_ts : String # auto generated from hname
  column vtitle_ts : String # auto generated from vname

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

  def self.glob_zh(qs : String)
    where("ztitle_ts LIKE %$%", BookUtils.scrub_zname(qs))
  end

  def self.glob_vi(qs : String, accent = false)
    scrub = BookUtils.scrub_vname(qs)
    query = where("vtitle_ts LIKE %$%", scrub).or("htitle_ts LIKE %$%", scrub)
    accent ? query.where("vtitle LIKE %$%", qs).or("htitle LIKE %$%", qs) : query
  end

  def self.upsert!(author : Author, ztitle : String, htitle : String? = nil, vtitle : String? = nil)
    find_by(author_id: author.id, ztitle: ztitle) || begin
      htitle ||= BookUtils.hanviet(ztitle)
      vtitle ||= BookUtils.get_vi_btitle(ztitle)

      ztslug = BookUtils.scrub_zname(ztitle)
      htslug = BookUtils.scrub_vname(htitle, "-")
      vtslug = BookUtils.scrub_vname(vtitle, "-")

      bhash = CoreUtils.digest32("#{ztitle}--#{author.zname}")
      bslug = htslug.split("-").first(7).push(bhash[0..3]).join("-")

      btitle = new(
        author_id: author.id, bhash: bhash, bslug: bslug,
        ztitle: ztitle, htitle: htitle, vtitle: vtitle,
        ztitle_ts: ztslug, htitle_ts: htslug, vtitle_ts: vtslug,
      )

      btitle.tap(&.save!)
    end
  end
end
