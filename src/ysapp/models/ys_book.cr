require "./_base"
require "./cv_book"
require "../_raw/raw_ys_book"
require "../../_data/wnovel/nv_info"
require "../../_data/wnovel/wn_link"
require "../../_util/tran_util"
require "../../mt_v1/data/v1_dict"

class YS::Ysbook
  include Clear::Model
  self.table = "ysbooks"

  primary_key type: :serial

  column nvinfo_id : Int32 = 0

  column btitle : String = ""
  column author : String = ""

  column cover : String = ""
  column intro : String = ""

  column genre : String = ""
  column btags : Array(String) = [] of String

  column voters : Int32 = 0
  column rating : Int32 = 0

  column status : Int32 = 0
  column shield : Int32 = 0

  column book_mtime : Int64 = 0_i64 # yousuu book update time
  column info_rtime : Int64 = 0_i64

  column word_count : Int32 = 0

  column crit_total : Int32 = 0 # total reviews
  column crit_count : Int32 = 0 # fetched reviews

  column list_total : Int32 = 0 # total book lists
  column list_count : Int32 = 0 # fetched book lists

  column sources : Array(String) = [] of String

  timestamps # created_at and updated_at

  # def lesser_source?(other_id : Int64)
  #   return false if other_id == 0 || !(other = Ysbook.find({id: other_id}))
  #   return true if self.voters <= other.voters

  #   puts "!! override: #{other_id} (#{other.voters}) \
  # => #{self.id} (#{self.voters})".colorize.yellow

  #   false
  # end

  def worth_saving?
    self.crit_total > 0 || self.list_total > 0 || self.voters > 10 || self.author.in?(Author.known_authors)
  end

  def sync_with_wn!(force : Bool = false) : Nil
    return unless nvinfo = self.get_nvinfo

    if self.voters >= nvinfo.zvoters
      nvinfo.set_zscores!(self.voters, self.rating)
    end

    nvinfo.set_utime(self.book_mtime)
    nvinfo.set_status(self.status)

    zgenres = [self.genre].concat(self.btags)
    nvinfo.set_vgenres(CV::GenreMap.zh_to_vi(zgenres))

    nvinfo.save!

    self.nvinfo_id = nvinfo.id.to_i

    M1::DbDict.init_wn_dict(self.nvinfo_id, nvinfo.bslug, nvinfo.vname)

    CV::WnLink.upsert!(self.nvinfo_id, "https://www.yousuu.com/book/#{self.id}")
    CV::WnLink.upsert!(self.nvinfo_id, self.sources)
  end

  def get_nvinfo(force : Bool = false)
    case self.nvinfo_id
    when 0    then create_nvinfo if force || worth_saving?
    when .> 0 then CV::Nvinfo.find({id: self.nvinfo_id})
    else           nil
    end
  end

  API_PATH    = "http://127.0.0.1:5010/_db/books"
  JSON_HEADER = HTTP::Headers{"content-type" => "application/json"}

  def create_nvinfo
    ztitle, zauthor = CV::BookUtil.fix_names(self.btitle, self.author)
    zintro = TextUtil.split_html(self.intro, true).join('\n')

    raise "uknown error" unless tl_data = TranUtil.tl_book(ztitle, zauthor, zintro)
    vtitle, vauthor, vintro = tl_data

    Log.info { "create new book: #{vtitle} -- #{vauthor}".colorize.yellow }

    author = CV::Author.upsert!(zauthor, vauthor)
    btitle = CV::Btitle.upsert!(ztitle, vtitle)
    nvinfo = CV::Nvinfo.upsert!(author, btitle, fix_names: true)

    nvinfo.zintro = zintro
    nvinfo.bintro = vintro
    nvinfo.scover = self.cover

    zgenres = [self.genre].concat(self.btags)
    nvinfo.set_vgenres(CV::GenreMap.zh_to_vi(zgenres))

    nvinfo
  end

  #########################################

  def self.load(y_bid : Int32)
    find({id: y_bid}) || new({id: y_bid})
  end

  def self.upsert!(raw_data : EmbedBook, force : Bool = false)
    model = load(raw_data.id)

    model.btitle = raw_data.btitle
    model.author = raw_data.author

    model.tap(&.save!)
  end

  def self.upsert!(raw_data : RawYsBook, force : Bool = false)
    model = load(raw_data.id)

    return if model.info_rtime >= raw_data.info_rtime
    model.info_rtime = raw_data.info_rtime

    model.btitle = raw_data.btitle
    model.author = raw_data.author

    model.cover = raw_data.cover
    model.intro = raw_data.intro

    model.genre = raw_data.genre
    model.btags = raw_data.btags

    model.voters = raw_data.voters
    model.rating = raw_data.rating

    model.status = raw_data.status
    model.shield = raw_data.shield

    model.book_mtime = raw_data.book_mtime
    model.info_rtime = raw_data.info_rtime

    model.word_count = raw_data.word_count
    model.crit_total = raw_data.crit_total
    model.list_total = raw_data.list_total

    model.sources = raw_data.sources

    model.sync_with_wn!
    model.tap(&.save!)
  end

  def self.crit_count(wn_id : Int64)
    query.find({nvinfo_id: wn_id}).try(&.crit_count) || begin
      query_stmt = "select count(*) from yscrits where nvinfo_id = $1"
      PG_DB.query_one query_stmt, wn_id, as: Int32
    end
  end
end
