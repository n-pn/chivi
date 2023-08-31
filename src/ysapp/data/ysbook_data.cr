require "./_base"

require "../../_util/book_util"
require "../../_util/tran_util"

require "../../_data/wnovel/wninfo"
require "../../_data/wnovel/wnlink"
require "../../mt_v1/data/v1_dict"
require "../../zroot/raw_json/raw_ysbook"

require "./wninfo_data"

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

  class_getter in_crits : Set(Int32) do
    PG_DB.query_all("select distinct(ysbook_id) from yscrits", as: Int32).to_set
  end

  def sync_with_wn!(force : Bool = false) : Nil
    return unless nvinfo = self.get_nvinfo

    if self.voters >= nvinfo.zvoters
      nvinfo.set_zscores!(self.voters, self.rating)
    end

    if nvinfo.bcover.empty?
      nvinfo.scover = self.cover
      # nvinfo.cache_cover(self.cover, persist: false)
    end

    nvinfo.set_utime(self.book_mtime)
    nvinfo.set_status(self.status)

    zgenres = [self.genre].concat(self.btags)
    nvinfo.set_vgenres(CV::GenreMap.zh_to_vi(zgenres))

    nvinfo.save!

    self.nvinfo_id = nvinfo.id.to_i

    M1::DbDict.init_wn_dict!(self.nvinfo_id, nvinfo.bslug, nvinfo.btitle_vi)

    CV::Wnlink.upsert!(self.nvinfo_id, "https://www.yousuu.com/book/#{self.id}")
    CV::Wnlink.upsert!(self.nvinfo_id, self.sources)
  end

  def get_nvinfo(force : Bool = false)
    case self.nvinfo_id
    when 0    then create_wnovel
    when .> 0 then CV::Wninfo.find({id: self.nvinfo_id})
    else           nil
    end
  end

  API_PATH    = "#{CV_ENV.be_host}/_db/books"
  JSON_HEADER = HTTP::Headers{"content-type" => "application/json"}

  def create_wnovel
    author_zh, btitle_zh = BookUtil.fix_names(author: self.author, btitle: self.btitle)
    zintro = TextUtil.split_html(self.intro, true).join('\n')

    if tl_data = TranUtil.tl_book(btitle_zh, author_zh, zintro)
      btitle_vi, author_vi, vintro = tl_data
    else
      raise "uknown translation error"
    end

    Log.info { "create new book: #{btitle_vi} -- #{author_vi}".colorize.yellow }

    author = CV::Author.upsert!(author_zh, author_vi)
    btitle = CV::Btitle.upsert!(btitle_zh, btitle_vi)
    nvinfo = CV::Wninfo.upsert!(author_zh, btitle_zh, name_fixed: true)

    nvinfo.zintro = zintro
    nvinfo.bintro = vintro

    zgenres = [self.genre].concat(self.btags)
    nvinfo.set_vgenres(CV::GenreMap.zh_to_vi(zgenres))

    nvinfo
  end

  #########################################

  def self.load(y_bid : Int32)
    find({id: y_bid}) || new({id: y_bid})
  end

  def self.upsert!(raw_data : ZR::EmbedYsbook, force : Bool = false)
    model = load(raw_data.id)

    model.btitle = raw_data.btitle
    model.author = raw_data.author

    model.tap(&.save!)
  end

  def self.upsert!(raw_data : ZR::RawYsbook, force : Bool = false)
    model = load(raw_data.id)

    return if !force && model.info_rtime >= raw_data.info_rtime
    model.info_rtime = raw_data.info_rtime

    model.btitle = raw_data.btitle
    model.author = raw_data.author

    model.cover = raw_data.cover
    model.intro = raw_data.intro

    model.genre = raw_data.genre
    model.btags = raw_data.btags

    if model.voters < raw_data.voters
      model.voters = raw_data.voters
      model.rating = raw_data.rating
    end

    if model.status < raw_data.status
      model.status = raw_data.status
    end

    if model.shield < raw_data.shield
      model.shield = raw_data.shield
    end

    if model.book_mtime <= raw_data.book_mtime
      model.book_mtime = raw_data.book_mtime
    end

    if model.word_count < raw_data.word_count
      model.word_count = raw_data.word_count
    end

    if model.crit_total < raw_data.crit_count
      model.crit_total = raw_data.crit_count
    end

    if model.list_total < raw_data.list_count
      model.list_total = raw_data.list_count
    end

    model.sources = raw_data.sources

    model.sync_with_wn!
    model.tap(&.save!)
  end

  def self.crit_count(wn_id : Int32)
    PG_DB.query_one?(<<-SQL, wn_id, as: Int32) || 0
      select count(*)::int from yscrits
      where nvinfo_id = $1
      SQL
  end

  def self.get_wn_id(yb_id : Int32)
    PG_DB.query_one(<<-SQL, yb_id, as: Int32)
      select nvinfo_id from ysbooks where id = $1
      order by id asc limit 1
      SQL
  end

  def self.update_crit_total(id : Int32, total : Int32)
    PG_DB.exec <<-SQL, total, id
    update ysbooks set crit_total = $1
    where id = $2 and crit_total < $1
    SQL
  end
end
