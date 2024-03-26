require "crorm"
require "../../_util/hash_util"
require "../../_util/char_util"

class WN::Corpus
  @[AlwaysInline]
  def self.line_cksum(line : String | Char, prev : UInt64 = HashUtil::BASIS_64)
    HashUtil.fnv_1a_64(line, prev)
  end

  @[AlwaysInline]
  def self.line_cksum(lines : Array(String))
    Slice(UInt64).new(lines.size) { |i| line_cksum(lines[i]) }
  end

  @[AlwaysInline]
  def self.u8_ids_to_bytes(u8_ids : Slice(UInt64))
    Slice(UInt64).new(u8_ids.size) { |i| u8_ids[i] }.to_unsafe_bytes
  end

  @[AlwaysInline]
  def self.clean_lines(lines : Array(String), to_canon = false, remove_blank = false)
    lines.reject!(&.blank?) if remove_blank
    lines.map! { |x| CharUtil.to_canon(x) } if to_canon
    lines
  end

  CACHE = {} of String => self

  def self.load(zname : String)
    CACHE[zname] ||= new(zname)
  end

  ###

  DIR = "/srv/chivi/zroot/corpus"
  Dir.mkdir_p(DIR)

  ###

  getter zhead_db : Crorm::SQ3
  getter zline_db : Crorm::SQ3
  getter vtran_db : Crorm::SQ3
  getter ctree_db : Crorm::SQ3

  def initialize(@zname : String)
    # Dir.mkdir_p(File.dirname("#{DIR}/#{zname}"))

    @zhead_db = Zhead.db("#{@zname}-zhead")
    @zline_db = Zline.db("#{@zname}-zline")
    @vtran_db = Vdata.db("#{@zname}-vtran")
    @ctree_db = Vdata.db("#{@zname}-ctree")
  end

  getter zhead_rw : DB::Connection { @zhead_db.open_rw }
  getter zline_rw : DB::Connection { @zline_db.open_rw }
  getter vtran_rw : DB::Connection { @vtran_db.open_rw }
  getter ctree_rw : DB::Connection { @ctree_db.open_rw }

  def open_tx(zhead = true, zline = true, vtran = false, ctree = false, &)
    self.zhead_rw.exec("begin") if zhead
    self.zline_rw.exec("begin") if zline
    self.vtran_rw.exec("begin") if vtran
    self.ctree_rw.exec("begin") if ctree

    yield

    self.zhead_rw.exec("commit") if zhead
    self.zline_rw.exec("commit") if zline
    self.vtran_rw.exec("commit") if vtran
    self.ctree_rw.exec("commit") if ctree
  ensure
    @zhead_rw = nil
    @zline_rw = nil
    @vtran_rw = nil
    @ctree_rw = nil
  end

  ZLINE_UPSERT_QUERY = <<-SQL
    insert or ignore into zlines(zline, i8_id)
    values ($1, $2)
    SQL

  ZHEAD_UPSERT_QUERY = <<-SQL
    insert into zheads(zorig, mtime, u1_ids) values ($1, $2, $3)
    on conflict (zorig) do nothing
    returning zorig
    SQL

  VDATA_UPSERT_QUERY = <<-SQL
    insert into vdatas(i8_id, vtype, vdata, cksum) values ($1, $2, $3, $4)
    on conflict (i8_id, vtype, cksum) do nothing
    returning i8_id
    SQL

  def add_file!(zorig : String, fpath : String,
                force_redo = false, to_canon = force_redo,
                remove_blank = force_redo, encoding : String = "UTF-8")
    lines = File.read_lines(fpath, encoding: encoding, chomp: true)
    lines = Corpus.clean_lines(lines, to_canon: to_canon, remove_blank: remove_blank)

    # mtime = File.info(fpath).modification_time
    add_part!(zorig, lines, mtime: 0, force_redo: force_redo)
  end

  def add_part!(zorig : String,
                lines : Array(String),
                mtime = Time.utc.to_unix,
                force_redo = false)
    u8_ids = Corpus.line_cksum(lines)

    saved_zorig = begin
      u1_ids = Corpus.u8_ids_to_bytes(u8_ids)
      self.zhead_rw.query_one?(ZHEAD_UPSERT_QUERY, zorig, mtime, u1_ids, as: String)
    end

    return {u8_ids, false} unless force_redo || saved_zorig

    lines.each_with_index do |line, idx|
      u8_id = u8_ids.unsafe_fetch(idx)
      self.zline_rw.exec(ZLINE_UPSERT_QUERY, line, u8_id.unsafe_as(Int64))
    end

    {u8_ids, true}
  end

  def add_data!(vtype : String, u8_ids : Slice(UInt64), vdatas : Array(String))
    raise "data not match" unless u8_ids.size == vdatas.size

    count = 0

    u8_ids.zip(vdatas) do |u8_id, vdata|
      i8_id = u8_id.unsafe_as(Int64)
      cksum = HashUtil.fnv_1a(vdata).unsafe_as(Int32)
      count += 1 if self.vtran_rw.query_one?(VDATA_UPSERT_QUERY, i8_id, vtype, vdata, cksum, as: Int32)
    end

    count
  end

  def get_texts_by_zorig(zorig : String)
    get_texts_by_zorig { nil }
  end

  def get_texts_by_zorig(zorig : String, &)
    u1_ids = @zhead_db.open_ro do |db|
      query = "select u1_ids from zheads where zorig = $1 limit 1"
      db.query_one?(query, zorig, as: Bytes)
    end

    if u1_ids
      u8_ids = u1_ids.unsafe_slice_of(UInt64)
      {get_texts_from_ids(u8_ids), u8_ids}
    else
      yield
    end
  end

  def get_texts_from_ids(u8_ids : Slice(UInt64))
    @zline_db.open_ro do |db|
      query = "select coalesce(zline, '') from zlines where i8_id = $1 limit 1"

      Array(String).new(u8_ids.size) do |i|
        db.query_one(query, u8_ids[i].unsafe_as(Int64), as: String)
      end
    end
  end

  ###

  class Zline
    def self.db_path(zname : String)
      "#{DIR}/#{zname}.db3"
    end

    class_getter init_sql = <<-SQL
      create table zlines(
        i8_id bigint not null primary key,
        zline varchar not null
      );
      SQL
    ##

    include Crorm::Model
    schema "zlines", :sqlite, multi: true

    field zline : String
    field i8_id : Int64

    def initialize(@zline, @i8_id = Corpus.line_cksum(zline).unsafe_as(Int64))
    end

    ###
  end

  class Zhead
    def self.db_path(zname : String)
      "#{DIR}/#{zname}.db3"
    end

    class_getter init_sql = <<-SQL
      create table zheads(
        zorig varchar not null,
        mtime bigint not null,
        u1_ids blob not null,
        primary key (zorig)
      );

      SQL

    ###

    include Crorm::Model
    schema "zheads", :sqlite, multi: true

    field zorig : String, pkey: true
    field mtime : Int64 = 0
    field u1_ids : Bytes = Bytes[]

    @[DB::Field(ignore: true, auto: true)]
    getter u8_ids : Array(UInt64) { @u1_ids.unsafe_slice_of(UInt64) }

    def initialize(@zorig,
                   lines : Array(String),
                   @mtime = Time.utc.to_unix,
                   @u8_ids = Corpus.line_ckcsum(lines))
      @u1_ids = Corpus.u8_ids_to_bytes(u8_ids)
    end
  end

  class Vdata
    def self.db_path(zname : String)
      "#{DIR}/#{zname}.db3"
    end

    class_getter init_sql = <<-SQL
      create table vdatas(
        i8_id bigint not null,
        vtype varchar not null,
        vdata text not null,
        cksum int not null,
        primary key (i8_id, vtype, cksum)
      );
      SQL

    include Crorm::Model
    schema "vdatas", :sqlite, multi: true

    field i8_id : Int64, pkey: true
    field vtype : String, pkey: true
    field cksum : Int32, pkey: true
    field vdata : String

    def initialize(@i8_id, @vtype, @vdata,
                   @cksum = HashUtil.fnv_1a_32(vdata).unsafe_as(Int32))
    end

    def self.new(zline : String, vtype : String, vdata : String, to_canon : Bool = false)
      zline = CharUtil.to_canon(zline) if to_canon
      i8_id = Corpus.line_cksum(zline).unsafe_as(Int64)
      new(i8_id, vtype, vdata)
    end
  end
end
