require "crorm"

require "../_util/book_util"
require "../_util/text_util"

require "./raw_html/raw_rmbook"
require "./raw_html/raw_rmstem"

class ZR::Rmstem
  class_getter db_path = "var/zroot/global/rmstems.db3"

  class_getter init_sql = <<-SQL
    CREATE TABLE stems(
      sname varchar not null,
      sn_id varchar not null,
      --
      rlink varchar not null default '',
      rtime bigint NOT NULL DEFAULT 0,
      --
      btitle varchar NOT NULL DEFAULT '',
      author varchar NOT NULL DEFAULT '',
      --
      utime bigint not null default 0,
      immut boolean NOT NULL DEFAULT false,
      --
      total int NOT NULL DEFAULT 0,
      avail int NOT NULL DEFAULT 0,
      lc_id varchar not null default '',
      --
      wn_id int not null default 0,
      stime bigint not null default 0,
      --
      _flag int NOT NULL DEFAULT 0,
      --
      primary key(sname, sn_id)
    );
    SQL

  ####

  include Crorm::Model
  schema "stems", :sqlite

  field sname : String, pkey: true
  field sn_id : String, pkey: true

  field rlink : String = ""   # remote catalog link
  field rtime : Int64 = 0_i64 # last remote update

  field btitle : String = "" # book title, formatted
  field author : String = "" # book author,, formatted

  field utime : Int64 = 0    # book content updated_at
  field immut : Bool = false # book content is immutable (dead of finished)

  field total : Int32 = 0   # total chap
  field avail : Int32 = 0   # chap cached to local disk
  field lc_id : String = "" # latest chap_id, to quick check

  field wn_id : Int32 = 0 # map to wninfo_id
  field stime : Int64 = 0 # last synced_at

  field _flag : Int32 = 0 # multi purposes, if < 0 then the stem is inactive

  @[DB::Field(ignore: true)]
  getter repo : Crorm::SQ3 { Chinfo.db(sname, sn_id) }

  # @[DB::Field(ignore: true)]
  # getter host : Rmhost { Rmhost.from_name!(@sname) }

  def initialize(@sname, @sn_id, @rlink = "")
  end

  def update!(mode : Int32 = 1) : self
    raw_stem = RawRmstem.from_link(@rlink, stale: Time.utc - reload_tspan(mode))

    # verify content changed by checking the latest chapter
    # not super reliable since some site reuse the latest chapter id for new chapter.
    # but since it is a rare occasion we can just ignore it

    if raw_stem.latest_cid == @lc_id
      return unless mode > 1 # always redo in force mode
    else
      @lc_id = raw_stem.latest_cid
    end

    chapters = raw_stem.chap_list
    self.repo.open_tx { |db| chapters.each(&.create!(db)) }

    @count = chapters.size
    @utime = raw_stem.update_int
    @rtime = Time.utc.to_unix # TODO: gen from html file modification time instead

    self.upsert!
  end

  private def reload_tspan(mode : Int32 = 1)
    case mode
    when 2 then @immut ? 30.minutes : 3.minutes # force mode
    when 1 then @immut ? 30.days : 30.minutes   # normal mode
    else        10.years                        # keep forever
    end
  end

  def prefetch_chap_htms!(w_size : Int32 = 6) : Int32
    query = "select rlink, spath from chinfos where cksum = ''"
    input = self.repo.query_all(query, as: {String, String})
    return 0 if input.empty?

    keep_dir = "var/.keep/rmchap/#{@sname}/#{@sn_id}"
    input.map! { |rlink, spath| {rlink, "#{keep_dir}/#{File.basename(spath)}.htm"} }

    if File.directory?(keep_dir)
      input.reject! { |_, spath| File.file?(spath) }
      return 0 if input.empty?
    else
      Dir.mkdir_p(keep_dir)
    end

    queue = input.map_with_index(1) { |rlink, spath, idx| {rlink, spath, idx} }
    host = Rmhost.from_name!(@sname)
    host.get_all!(queue, w_size)
  end

  def update_avail_count!
    @avail = self.repo.query_one("select count(*) form chinfos where cksum <> ''", as: Int32)
    query = @@schema.update_stmt(update_fields: ["avail"])
    self.update!(query: query)
  end
end
