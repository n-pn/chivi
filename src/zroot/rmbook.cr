require "crorm"

require "../_util/book_util"
require "../_util/time_util"
require "../_util/text_util"

require "./html_parser/raw_rmbook"

class ZR::Rmbook
  class_getter init_sql = <<-SQL
    CREATE TABLE rmbooks(
      id text NOT NULL PRIMARY KEY,
      wn_id int not null default 0,
      --
      btitle text NOT NULL DEFAULT '',
      author text NOT NULL DEFAULT '',
      --
      cover text NOT NULL DEFAULT '',
      intro text NOT NULL DEFAULT '',
      --
      genre text NOT NULL DEFAULT '',
      xtags text NOT NULL DEFAULT '',
      --
      voters int NOT NULL DEFAULT 0,
      rating int NOT NULL DEFAULT 0,
      --
      status_str text NOT NULL DEFAULT 0,
      update_str text NOT NULL DEFAULT 0,
      latest_cid text not null default '',
      --
      chap_count int NOT NULL DEFAULT 0,
      chap_avail int NOT NULL DEFAULT 0,
      --
      rtime bigint NOT NULL DEFAULT 0,
      _flag int NOT NULL DEFAULT 0
    );
    SQL

  def self.db_path(sname : String)
    "var/zroot/rmseed/#{sname}.db3"
  end

  def self.load(sname : String, id : String)
    find(id, db: db(sname)) || new(id: id)
  end

  ####

  include Crorm::Model
  schema "rmbooks", :sqlite, multi: true

  field id : String, pkey: true
  field wn_id : Int32 = 0 # official chivi id

  field btitle : String = ""
  field author : String = ""

  field cover : String = ""
  field intro : String = ""

  field genre : String = ""
  field xtags : String = ""

  field status_str : String = ""
  field update_str : String = ""
  field latest_cid : String = ""

  field chap_count : Int32 = 0
  field chap_avail : Int32 = 0

  field rtime : Int64 = 0_i64
  field _flag : Int32 = 0

  def initialize(@id)
  end

  def update_wninfo(wninfo : CV::Wninfo, fake_rating : Bool = false)
    # TODO: update in wnstats instead
    if wninfo.zvoters == 0 && fake_rating
      voters = Random.rand(20..50)
      rating = Random.rand(50..60)
      wninfo.set_zscores!(voters, rating)
    end

    wninfo.scover = @cover if wninfo.bcover.empty?

    # wninfo.set_utime(@book_mtime)
    # wninfo.set_status(@status)

    if wninfo.vgenres.empty?
      genres = [@genre].concat(@xtags.split('\t')).reject!(&.empty?).uniq!
      wninfo.set_genres(genres)
    end

    wninfo.save!

    wninfo
  end

  ###

  def self.from_html_file(fpath : String,
                          sname = File.basename(File.dirname(fpath)),
                          sn_id = File.basename(fpath, ".htm"),
                          force = false)
    bhtml = File.read(fpath)
    rtime = File.info(fpath).modification_time.to_unix

    from_html(bhtml, sname: sname, sn_id: sn_id, rtime: rtime, force: force)
  end

  def self.from_html(bhtml : String,
                     sname : String, sn_id : String,
                     rtime = Time.utc.to_unix, force = false)
    entry = self.load(sname, sn_id)
    return if !force && entry.rtime >= rtime

    raw_data = RawRmbook.new(bhtml, sname: sname)
    entry.rtime = rtime

    entry.btitle = raw_data.btitle
    entry.author = raw_data.author

    entry.cover = raw_data.cover
    entry.intro = raw_data.intro

    entry.genre = raw_data.genre
    entry.xtags = raw_data.xtags

    entry.status_str = raw_data.status_str
    entry.update_str = raw_data.update_str
    entry.latest_cid = raw_data.latest_cid

    # entry.chap_count = raw_data.chap_count

    entry
  end
end
