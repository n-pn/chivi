require "./ch_info"
require "../_util/r2_client"

class CV::ChRepo
  DIR = "var/chaps/texts"

  getter sn_id : Int32
  getter s_bid : Int32
  getter stype : Int8

  getter sauce_path : String { File.join(@root_dir, "sauce.tab") }
  getter patch_path : String { File.join(@root_dir, "patch.tab") }

  def initialize(sname : String, @s_bid : Int32)
    @root_dir = "#{DIR}/#{sname}/#{s_bid}"
    @sn_id, @stype = ChSeed.map_sname(sname)

    db_path = File.join(@root_dir, "index.db")
    existed = File.exists?(db_path) || pull_r2!(db_path)

    @repo = Crorm::Adapter.new("sqlite3://#{db_path}")
    return if existed

    init_db!
    seed_db!
  end

  def pull_r2!(db_path : String) : Bool
    return false unless File.exists?(File.join(@root_dir, "index.r2"))
    R2Client.download(db_path.sub(DIR, "texts"), db_path)
  end

  def count
    @repo.scalar("chinfos", "count (ch_no)")
  end

  KEEP_FIELDS = {"ch_no", "sn_id", "s_bid", "s_cid"}

  def bulk_upsert(infos : Array(Chinfo))
    @repo.open_tx do |cnn|
      infos.each do |entry|
        fields, values = entry.get_changes
        next if fields.empty?

        @repo.upsert(cnn, "chinfos", fields, values, "(ch_no)", nil) do
          keep_fields = fields.reject(&.in?("ch_no"))
          @repo.upsert_stmt(keep_fields) { |field| "excluded.#{field}" }
        end
      end
    end
  end

  def upsert(entry : Chinfo)
    fields, values = entry.get_changes

    @repo.open do |db|
      @repo.upsert(db, "chinfos", fields, values, "(ch_no)", nil) do
        keep_fields = fields.reject(&.== "ch_no")
        @repo.upsert_stmt(keep_fields) { |field| "excluded.#{field}" }
      end
    end
  end

  def get(ch_no : Int32) : Chinfo?
    query = "select * from chinfos where ch_no = ? limit 1"
    @repo.open(&.query_one? query, ch_no, as: Chinfo)
  end

  def all(min : Int32, max : Int32, order : String = "asc")
    query = <<-SQL
      select * from "chinfos"
      where ch_no >= ? and ch_no <= ?
      order by ch_no #{order}
    SQL

    @repo.open(&.query_all(query, min, max, as: Chinfo))
  end

  def empty_chaps
    query = <<-SQL
      select * from "chinfos"
      where c_len = 0
      order by ch_no asc
    SQL

    @repo.open(&.query_all(query, as: Chinfo))
  end

  def get_title(ch_no : Int32) : String?
    query = "select title from chinfos where ch_no = ? limit 1"
    @repo.open(&.query_one? query, ch_no, as: String)
  end

  def match_ch_no(title : String, ch_no : Int32) : Int32
    query = <<-SQL
      select ch_no from chinfos
      where ch_no >= ? and ch_no <= ? and title = ?
      order by ch_no desc
      limit 1
    SQL

    @repo.open(&.query_one? query, ch_no &- 20, ch_no &+ 20, title, as: Int32) || ch_no
  end

  def nearby_chvol(ch_no : Int32) : String
    query = <<-SQL
      select chvol from chinfos
      where ch_no <= ? and chvol <> ''
      order by ch_no desc
      limit 1
    SQL

    @repo.open(&.query_one? query, ch_no, as: String) || ""
  end

  private def init_db! : Nil
    Dir.mkdir_p(@root_dir)

    @repo.open do |db|
      db.exec "drop table if exists chinfos;"
      db.exec <<-SQL
        create table chinfos (
          ch_no int primary key,

          title text default "" not null,
          chvol text default "" not null,

          p_len int default 0 not null,
          c_len int default 0 not null,

          utime bigint default 0 not null,
          uname text default "" not null,

          sn_id int not null,
          s_bid int not null,
          s_cid int not null
        );
      SQL
    end
  end

  def seed_db!
    hash = {} of Int32 => Chinfo

    pages = Dir.glob(File.join(@root_dir, "*.tsv"))
    pages.sort_by! { |x| File.basename(x, ".tsv").to_i }
    pages.each { |x| hash = read_file(x, hash) }

    infos = hash.values.sort_by!(&.ch_no.not_nil!)
    bulk_upsert(infos) unless infos.empty?
  rescue err
    Log.error(exception: err) { "error seeding [#{@sn_id}/#{@s_bid}]".colorize.yellow }
  end

  def sync_db!
    hash = {} of Int32 => Chinfo

    hash = read_file(sauce_path, hash) if File.exists?(sauce_path)
    hash = read_file(patch_path, hash) if File.exists?(patch_path)

    infos = hash.values.sort_by!(&.ch_no.not_nil!)
    bulk_upsert(infos) unless infos.empty?
  end

  def read_file(file : String | Path, hash = {} of Int32 => Chinfo)
    File.read_lines(file).each do |line|
      cols = line.split('\t')
      next if cols.size < 4

      entry = Chinfo.new(@sn_id, @s_bid, cols)
      hash[entry.ch_no!] = entry
    end

    hash
  end

  def load_from_tsv(file : String)
    input = read_file(file).values.sort_by!(&.ch_no.not_nil!)
    bulk_upsert(input) unless input.empty?
    input.last
  end
end
