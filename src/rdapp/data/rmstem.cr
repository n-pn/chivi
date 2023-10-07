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
  getter crepo : Chrepo do
    Chrepo.load(sroot: "rm#{@sname}/#{@sn_id}").tap do |repo|
      repo.zname = "#{@btitle_zh} #{@author_zh}"
      repo.chmax = @chap_count
      repo.wn_id = @wn_id
      repo.gifts = 2
      repo.plock = 3
    end
  end

  def chap_count=(@chap_count : Int32)
    self.crepo.chmax = chap_count
  end

  def initialize(@sname, @sn_id, @rlink = "")
  end

  def update!(crawl : Int32 = 1, regen : Bool = false) : self | Nil
    begin
      stale = Time.utc - reload_tspan(crawl)
      # raw_stem = RawRmstem.from_link(@rlink, stale: stale)
      raw_stem = RawRmstem.from_stem(@sname, @sn_id, stale: stale)
    rescue ex
      case ex.message || ""
      when .ends_with?("301"), .ends_with?("404")
        @rtime = Time.utc.to_unix
        query = "update #{@@schema.table} set rtime = $1, _flag = -404 where sname = $2 and sn_id = $3"
        @@db.exec query, @rtime, @sname, @sn_id
        return self
      else
        raise ex
      end
    end

    # verify content changed by checking the latest chapter
    # not super reliable since some site reuse the latest chapter id for new chapter.
    # but since it is a rare occasion we can just ignore it
    if raw_stem.latest_cid == @latest_cid
      return unless regen # always redo in force crawl
    else
      @latest_cid = raw_stem.latest_cid
    end

    @latest_cid = raw_stem.latest_cid

    chapters = raw_stem.extract_crepo!
    self.crepo.upsert_zinfos!(chapters)

    # TODO: translate to vietnamese

    @chap_count = chapters.size

    unless raw_stem.update_str.empty?
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

  private def reload_tspan(crawl : Int32 = 1)
    case crawl
    when 2 then @status_int > 1 ? 30.minutes : 3.minutes # force crawl
    when 1 then @status_int > 1 ? 15.days : 30.minutes   # normal crawl
    else        10.years                                 # keep forever
    end
  end

  # def prefetch_chap_htms!(w_size : Int32 = 6) : Int32
  #   query = "select rlink, spath from chinfos where cksum = ''"
  #   input = self.crepo.query_all(query, as: {String, String})
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
  #   @chap_avail = self.crepo.query_one(select_query, as: Int32)

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

  def self.build_select_sql(
    btitle : String? = nil, author : String? = nil, status : Int32? = nil,
    wn_id : Int32? = nil, sname : String? = nil, genre : String? = nil,
    order : String = "mtime"
  )
    args = [] of String | Int32

    query = String.build do |sql|
      sql << "select * from #{@@schema.table} where 1 = 1"

      if sname
        args << sname
        sql << " and sname = $1"
      end

      if genre
        args << genre
        sql << " and genre_vi ilike '%' || $#{args.size} || '%'"
      end

      if wn_id
        args << wn_id
        sql << " and wn_id = $#{args.size}"
      end

      if status
        args << status
        sql << " and status = $#{args.size}"
      end

      if btitle
        args << btitle
        field = btitle =~ /\p{Han}/ ? "btitle_zh" : "btitle_vi"
        sql << " and #{field} ilike '%' || $#{args.size} || '%'"
      end

      if author
        args << author
        field = author =~ /\p{Han}/ ? "author_zh" : "author_vi"
        sql << " and #{field} ilike '%' || $#{args.size} || '%'"
      end

      case order
      when "rtime" then sql << " order by rtime desc"
      when "utime" then sql << " order by update_int desc"
      when "count" then sql << " order by chap_count desc"
      end

      sql << " limit $#{args.size &+ 1} offset $#{args.size &+ 2}"
    end

    {query, args}
  end
end
