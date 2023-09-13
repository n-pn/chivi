require "crorm"
require "../_util/hash_util"
require "../_util/char_util"

class ZR::Corpus
  @[AlwaysInline]
  def self.line_cksum(line : String | Char, prev : UInt64 = HashUtil::BASIS_64)
    HashUtil.fnv_1a_64(line, prev)
  end

  @[AlwaysInline]
  def self.line_cksum(lines : Enumerable(String))
    lines.map { |line| line_cksum(line) }
  end

  @[AlwaysInline]
  def self.u8_ids_to_bytes(u8_ids : Enumerable(UInt64))
    Slice(UInt64).new(u8_ids.size) { |i| u8_ids[i] }.to_unsafe_bytes
  end

  @[AlwaysInline]
  def self.clean_lines(lines : Array(String), to_canon = false, remove_blank = false)
    lines.reject!(&.blank?) if remove_blank
    lines.map! { |x| CharUtil.to_canon(x) } if to_canon
    lines
  end

  DIR = "var/zroot/corpus"
  Dir.mkdir_p(DIR)

  ###

  getter zhead_rw : DB::Connection { Zhead.db("#{@zname}-zhead").open_rw }
  getter zline_rw : DB::Connection { Zline.db("#{@zname}-zline").open_rw }
  getter vtran_rw : DB::Connection { Vdata.db("#{@zname}-vtran").open_rw }
  getter ctree_rw : DB::Connection { Vdata.db("#{@zname}-ctree").open_rw }

  def initialize(@zname : String)
    # Dir.mkdir_p(File.dirname("#{DIR}/#{zname}"))
  end

  def init_dbs!(no_zhead = false, no_zline = false, no_vtran = false, no_ctree = false)
    puts self.zhead_rw.scalar "select 'init zhead'" unless no_zhead
    puts self.zline_rw.scalar "select 'init zline'" unless no_zline
    puts self.vtran_rw.scalar "select 'init vtran'" unless no_vtran
    puts self.ctree_rw.scalar "select 'init ctree'" unless no_ctree
  end

  def open_tx(&)
    open_tx
    yield
    close_tx
  end

  def open_tx
    @zhead_rw.try(&.exec("begin"))
    @zline_rw.try(&.exec("begin"))
    @vtran_rw.try(&.exec("begin"))
  end

  def close_tx
    @zhead_rw.try(&.exec("commit"))
    @zline_rw.try(&.exec("commit"))
    @vtran_rw.try(&.exec("commit"))
  end

  def finalize
    @zhead_rw.try(&.close) rescue nil
    @zline_rw.try(&.close) rescue nil
    @vtran_rw.try(&.close) rescue nil
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

  def add_data!(vtype : String, u8_ids : Array(UInt64), vdatas : Array(String))
    raise "data not match" unless u8_ids.size == vdatas.size

    count = 0

    u8_ids.zip(vdatas) do |u8_id, vdata|
      i8_id = u8_id.unsafe_as(Int64)
      cksum = HashUtil.fnv_1a(vdata).unsafe_as(Int32)
      count += 1 if self.vtran_rw.query_one?(VDATA_UPSERT_QUERY, i8_id, vtype, vdata, cksum, as: Int32)
    end

    count
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
