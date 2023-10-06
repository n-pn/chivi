require "../../_data/_data"

require "../_raw/raw_rmbook"
require "../_raw/raw_rmstem"

require "./chrepo"

class RD::Rmstem
  class_getter db : DB::Database = PGDB

  include Crorm::Model
  schema "rmstems", :postgres, strict: false

  field sname : String, pkey: true
  field sn_id : String, pkey: true

  field rlink : String = ""   # remote catalog link
  field rtime : Int64 = 0_i64 # last remote update

  field btitle_zh : String = ""
  field author_zh : String = ""

  field btitle_vi : String = ""
  field author_vi : String = ""

  field cover_rm : String = ""
  field cover_cv : String = ""

  field intro_zh : String = ""
  field intro_vi : String = ""

  field genre_zh : String = ""
  field genre_vi : String = ""

  field status_str : String = ""
  field status_int : Int16 = 0_i16

  field update_str : String = ""
  field update_int : Int64 = 0_i64

  field chap_count : Int32 = 0
  field chap_avail : Int32 = 0
  field latest_cid : String = ""

  field wn_id : Int32 = 0 # map to wninfo_id
  field stime : Int64 = 0 # last synced_at
  field _flag : Int16 = 0 # multi purposes, if < 0 then the stem is inactive

  @[DB::Field(ignore: true, auto: true)]
  @[JSON::Field(ignore: true)]
  getter clist : Chrepo { Chrepo.load("rm#{@sname}/#{@sn_id}") }

  def initialize(@sname, @sn_id, @rlink = "")
  end

  def update!(mode : Int32 = 1) : self | Nil
    # raw_stem = RawRmstem.from_link(@rlink, stale: Time.utc - reload_tspan(mode))
    raw_stem = RawRmstem.from_stem(@sname, @sn_id, stale: Time.utc - reload_tspan(mode))

    # verify content changed by checking the latest chapter
    # not super reliable since some site reuse the latest chapter id for new chapter.
    # but since it is a rare occasion we can just ignore it

    if raw_stem.latest_cid == @latest_cid
      return unless mode > 1 # always redo in force mode
    else
      @latest_cid = raw_stem.latest_cid
    end

    chapters = raw_stem.extract_clist!
    self.clist.upsert_zinfos!(chapters)

    # TODO: translate to vietnamese

    @chap_count = chapters.size

    unless raw_stem.update_str
      @update_str = raw_stem.update_str
      @update_int = raw_stem.update_int
    end

    # TODO: check if status exist and is updated
    unless raw_stem.status_str.empty?
      @status_str = raw_stem.status_str
      @status_int = raw_stem.status_int
    end

    # TODO: gen from html file modification time instead
    @rtime = Time.utc.to_unix
    self.upsert!(db: @@db)
  end

  private def reload_tspan(mode : Int32 = 1)
    case mode
    when 2 then @status_int > 1 ? 30.minutes : 3.minutes # force mode
    when 1 then @status_int > 1 ? 15.days : 30.minutes   # normal mode
    else        10.years                                 # keep forever
    end
  end

  # def prefetch_chap_htms!(w_size : Int32 = 6) : Int32
  #   query = "select rlink, spath from chinfos where cksum = ''"
  #   input = self.clist.query_all(query, as: {String, String})
  #   return 0 if input.empty?

  #   keep_dir = "var/.keep/rmchap/#{@sname}/#{@sn_id}"
  #   input.map! { |rlink, spath| {rlink, "#{keep_dir}/#{File.basename(spath)}.htm"} }

  #   if File.directory?(keep_dir)
  #     input.reject! { |_, spath| File.file?(spath) }
  #     return 0 if input.empty?
  #   else
  #     Dir.mkdir_p(keep_dir)
  #   end

  #   queue = input.map_with_index(1) { |rlink, spath, idx| {rlink, spath, idx} }
  #   host = Rmhost.from_name!(@sname)
  #   host.get_all!(queue, w_size)
  # end

  # def update_avail_count!
  #   select_query = "select count(*) form chinfos where cksum <> ''"
  #   @chap_avail = self.clist.query_one(select_query, as: Int32)

  #   update_query = @@schema.update_stmt(update_fields: ["chap_avail"])
  #   @@db.exec(update_query, @chap_avail, @sname, @sn_id)
  # end

  ###

  def self.find(sname : String, sn_id : String)
    get(sname, sn_id, &.<< "where sname = $1 and sn_id = $2")
  end

  def self.find!(sname : String, sn_id : String)
    get!(sname, sn_id, &.<< "where sname = $1 and sn_id = $2")
  end

  def self.from_html(bhtml : String,
                     sname : String, sn_id : String,
                     rtime = Time.utc.to_unix, force = false)
    entry = self.find(sname, sn_id) || new(sname, sn_id)
    return if !force && entry.rtime >= rtime

    input = RawRmbook.new(bhtml, sname: sname)
    return if input.btitle.empty?

    entry.btitle_zh = input.btitle
    entry.author_zh = input.author

    entry.cover_rm = input.cover
    entry.intro_zh = input.intro

    entry.genre_zh = "#{input.genre}\t#{input.xtags.gsub(" ", "\t")}".strip

    entry.status_int = input.status_int
    entry.status_str = input.status_str
    entry.update_str = input.update_str
    entry.update_int = input.update_int
    entry.latest_cid = input.latest_cid

    # entry.chap_count = raw_data.chap_count
    entry.rtime = rtime

    entry
  end
end
