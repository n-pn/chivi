require "../_base"
require "../shared/*"

# require "../../mt_v1/core/m1_core"
require "../../_util/ram_cache"

require "./author"
require "./btitle"
require "./bcover"

require "./wnlink"

require "./wninfo_inner"

class CV::Wninfo
  include Clear::Model

  self.table = "wninfos"
  primary_key type: :serial

  column subdue_id : Int64 = 0 # in case of duplicate entries, this column will point to the better one

  # getter dt_ii : Int32 { (id > 0 ? id &+ 20 : id * -5).to_i &* 10000 }

  # belongs_to author : Author, foreign_key_type: Int32
  # belongs_to btitle : Btitle, foreign_key_type: Int32

  # getter seed_list : Nslist { Nslist.new(self) }

  # column vname : String = ""
  # column bhash : String # unique string generate from zh_title & zh_author
  column bslug : String # unique string generate from hv_title & bhash

  ##############

  column btitle_zh : String = ""
  column btitle_vi : String = ""
  column btitle_hv : String = ""

  column author_zh : String = ""
  column author_vi : String = ""

  ###########

  column igenres : Array(Int32) = [] of Int32
  property vgenres : Array(String) { GenreMap.to_str(igenres) }

  column vlabels : Array(String) = [] of String

  ###########

  column scover : String = "" # original seed cover url
  column bcover : String = "" # cached book cover path

  column zintro : String = "" # book introduction in chinese
  column bintro : String = "" # book introduction in chinese

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
  column utime : Int64 = 0 # value by minute from the epoch, max value of wnseed utime and ys_utime

  # ranking

  column weight : Int32 = 0
  column voters : Int32 = 0
  column rating : Int32 = 0

  column zvoters : Int32 = 0
  column zrating : Int32 = 0

  column vvoters : Int32 = 0
  column vrating : Int32 = 0

  column chap_count : Int32 = 0 # chap views count
  column word_count : Int32 = 0 # chap views count

  column mark_count : Int32 = 0 # discuss topic count
  column view_count : Int32 = 0 # user tracking count

  column post_count : Int32 = 0
  column board_bump : Int64 = 0

  timestamps # created_at and updated_at

  scope :filter_btitle do |input|
    if input =~ /\p{Han}/
      where("btitle_zh %> ?", input)
    else
      where("_btitle_ts_ like '%' || scrub_name(?) || '%'", input)
    end
  end

  scope :filter_author do |input|
    if input =~ /\p{Han}/
      where("author_zh %> ?", input)
    else
      where("_author_ts_ like '%' || scrub_name(?) || '%'", input)
    end
  end

  scope :filter_wnseed do |input|
    stmt = "id IN (SELECT wn_id FROM wnseeds WHERE sname = ?"
    stmt += " AND chap_total > 0" unless input[0]? == '!'
    stmt += ")"

    where(stmt, input)
  end

  scope :filter_origin do |input|
    stmt = "id IN (SELECT book_id FROM wnlinks WHERE type = 1 AND name = ?)"
    where(stmt, input)
  end

  scope :filter_genres do |input|
    input ? where("igenres @> ?", GenreMap.map_int(input.split('+'))) : self
  end

  scope :filter_viuser do |uname, bmark|
    if uname && (viuser = Viuser.load!(uname))
      where_clause = "viuser_id=#{viuser.id}"
      where_clause += " and status=#{Ubmemo.status(bmark)}" if bmark
      where("id IN (SELECT nvinfo_id from ubmemos where #{where_clause})")
    else
      self
    end
  end

  scope :filter_tagged do |input|
    input ? where("vlabels @> ?", input.split("+").map(&.strip)) : self
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

  getter orig_links : Array(Wnlink) { Wnlink.all_origs(self.id.to_i) }

  include WninfoInner

  def canonical_path
    "/wn/#{self.id}-#{self.bslug}"
  end

  #########################################

  def self.preload(ids : Array(Int32))
    ids.empty? ? [] of self : query.where("id = any(?)", ids)
  end

  class_getter total : Int32 { query.count.to_i }

  CACHE_INT = RamCache(Int32, self).new
  CACHE_STR = {} of String => Int32

  def self.find(sql : String) : self | Nil
    query.where(sql).limit(1).first
  end

  def self.cache!(nvinfo : self)
    CACHE_INT.set(nvinfo.id, nvinfo)
  end

  def self.load!(id : Int32)
    CACHE_INT.get(id) { find!({id: id}) }
  end

  def self.load!(bslug : String)
    if nvinfo_id = CACHE_STR[bslug]?
      load!(nvinfo_id)
    elsif model = find("bslug like '#{bslug}%'")
      CACHE_STR[model.bslug] = model.id
      CACHE_INT.get(model.id) { model }
    end
  end

  def self.get(author : String, btitle : String)
    find({author_zh: author, btitle_zh: btitle})
  end

  def self.upsert!(author_zh : String, btitle_zh : String, name_fixed : Bool = false)
    unless name_fixed
      author_zh, btitle_zh = BookUtil.fix_names(author: author_zh, btitle: btitle_zh)
    end

    get(author: author_zh, btitle: btitle_zh) || begin
      entry = self.new({author_zh: author_zh, btitle_zh: btitle_zh})

      entry.author_vi = Author.get_vname(author_zh)
      entry.btitle_vi, entry.btitle_hv = Btitle.get_names(btitle_zh)

      entry.set_bslug(TextUtil.slugify(entry.btitle_hv))

      entry.save!
      self.mkdirs!(entry.id)

      entry
    end
  end

  def self.get_btitle_vi(id : Int32) : String
    stmt = "select btitle_vi from wninfos where id = $1 limit 1"
    PGDB.query_one(stmt, id, as: String)
  end

  def self.mkdirs!(wn_id : Int32)
    Dir.mkdir_p("var/wnapp/chinfo/#{wn_id}")
    Dir.mkdir_p("var/wnapp/chtext/#{wn_id}")
    Dir.mkdir_p("var/wnapp/chtran/#{wn_id}")
  end
end
