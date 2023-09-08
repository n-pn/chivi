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

  def self.head_cksum(lines : Enumerable(String))
    cksum = line_cksum(lines[0])

    1.upto(lines.size &- 1) do |idx|
      line = lines.unsafe_fetch(idx)
      cksum = line_cksum('\n', cksum)
      cksum = line_cksum(line, cksum)
    end

    cksum
  end

  @[AlwaysInline]
  def self.clean_lines(lines : Array(String), to_canon = false, remove_empty = true)
    lines.reject!(&.empty?) if remove_empty
    lines.map! { |x| CharUtil.to_canon(x) } if to_canon
    lines
  end

  @[AlwaysInline]
  def self.head_r_ids(l_ids : Enumerable(UInt64))
    Slice(UInt64).new(l_ids.size) { |i| l_ids[i] }.to_unsafe_bytes
  end

  DIR = "var/zroot/corpus"
  Dir.mkdir_p(DIR)

  ###

  getter zhead_db : DB::Connection { Zhead.db(@ctype).open_rw }
  getter zline_db : DB::Connection { Zline.db(@ctype).open_rw }

  def initialize(@ctype : String)
    Dir.mkdir_p(File.dirname("#{DIR}/#{ctype}"))
  end

  def init_zdata!
    puts self.zhead_db.scalar "select 'init zhead'"
    puts self.zline_db.scalar "select 'init zline'"
  end

  def open_tx(&)
    open_tx
    yield
    close_tx
  end

  def open_tx
    @zhead_db.try(&.exec("begin"))
    @zline_db.try(&.exec("begin"))
  end

  def close_tx
    @zhead_db.try(&.exec("commit"))
    @zline_db.try(&.exec("commit"))
  end

  def finalize
    close_tx rescue nil
    @zhead_db.try(&.close) rescue nil
    @zline_db.try(&.close) rescue nil
  end

  ZLINE_UPSERT_QUERY = <<-SQL
    insert or ignore into zlines("line", "z_id")
    values ($1, $2)
    SQL

  ZHEAD_UPSERT_QUERY = <<-SQL
    insert into zheads(zorig, cksum, r_ids) values ($1, $2, $3)
    on conflict(zorig) do update set cksum = excluded.cksum, r_ids = excluded.r_ids
    where zheads.cksum != excluded.cksum
    returning zorig
    SQL

  def add_file!(zorig : String, fpath : String,
                force_redo = false, to_canon = force_redo,
                remove_empty = force_redo, encoding : String = "UTF-8")
    lines = File.read_lines(fpath, encoding: encoding, chomp: true)
    lines = Corpus.clean_lines(lines, to_canon: to_canon, remove_empty: remove_empty)
    add_part!(zorig, lines, force_redo: force_redo)
  end

  def add_part!(zorig : String, lines : Array(String), force_redo = false)
    r_ids = Corpus.line_cksum(lines)

    saved_zorig = begin
      head_cksum = Corpus.head_cksum(lines).unsafe_as(Int64)
      head_r_ids = Corpus.head_r_ids(r_ids)
      self.zhead_db.query_one?(ZHEAD_UPSERT_QUERY, zorig, head_cksum, head_r_ids, as: String)
    end

    return false unless force_redo || saved_zorig

    lines.each_with_index do |line, idx|
      r_id = r_ids.unsafe_fetch(idx)
      self.zline_db.exec(ZLINE_UPSERT_QUERY, line, r_id.unsafe_as(Int64))
    end

    true
  end

  class Zline
    def self.db_path(ctype : String)
      "#{DIR}/#{ctype}-zline.db3"
    end

    class_getter init_sql = <<-SQL
      create table zlines(
        'z_id' bigint not null primary key,
        'line' varchar not null
      );
      SQL
    ##

    include Crorm::Model
    schema "zlines", :sqlite, multi: true

    field line : String
    field z_id : Int64

    def initialize(@line, @z_id = Corpus.line_cksum(line).unsafe_as(Int64))
    end

    ###
  end

  class Zhead
    def self.db_path(ctype : String)
      "#{DIR}/#{ctype}-zhead.db3"
    end

    class_getter init_sql = <<-SQL
      create table zheads(
        zorig varchar not null,
        cksum bigint not null,
        r_ids blob not null,
        primary key (zorig)
      );

      create index cksum on zheads(cksum);
      SQL

    ###

    include Crorm::Model
    schema "zheads", :sqlite, multi: true

    field zorig : String, pkey: true
    field cksum : Int64 = 0
    field r_ids : Bytes = Bytes[]

    @[DB::Field(ignore: true, auto: true)]
    getter l_ids : Array(UInt64) { @r_ids.unsafe_slice_of(UInt64) }

    def initialize(@zorig, input : Array(String), @l_ids = Corpus.line_ckcsum(input))
      @cksum = Corpus.head_cksum(input).unsafe_as(Int64)
      @r_ids = Slice(UInt64).new(l_ids.size) { |i| l_ids[i] }.to_unsafe_bytes
    end
  end
end
