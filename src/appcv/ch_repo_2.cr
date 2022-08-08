require "./ch_info_2"
require "../tools/r2_client"

# require "../appcv/remote/remote_info"

class CV::ChRepo2
  # include Crorm::Query(ChInfo2)

  DIR = "var/chtexts"

  getter sn_id : Int32
  getter s_bid : Int32
  getter stype : Int8

  getter origs_path : String { File.join(@root_dir, "origs.tab") }
  getter patch_path : String { File.join(@root_dir, "patch.tab") }

  def initialize(@sname : String, @s_bid)
    @root_dir = "#{DIR}/#{sname}/#{s_bid}"
    @sn_id, @stype = ChSeed.map_sname(sname)

    db_path = File.join(@root_dir, "index.db")
    existed = File.exists?(db_path) || pull_r2!

    @repo = Crorm::Adapter.new("sqlite3://#{db_path}")
    return if existed

    init_db!
    seed_db!
  end

  def pull_r2! : Bool
    r2_path = File.join(@root_dir, "index.r2")
    return false unless File.exists?(r2_path)

    r2_href = r2_path.sub("var/chtexts", "/texts")
    R2Client.download(r2_href, r2_path)
  end

  def count
    @repo.scalar("chinfos", "count (*)")
  end

  def bulk_upsert(infos : Array(ChInfo2))
    @repo.transaction do |cnn|
      infos.each do |entry|
        fields, values = entry.changes

        @repo.upsert(cnn, "chinfos", fields, values, "(ch_no)", "chinfos.utime < excluded.utime") do
          keep_fields = fields.reject(&.in?("ch_no"))
          @repo.upsert_stmt(keep_fields) { |field| "excluded.#{field}" }
        end
      end
    end
  end

  def upsert(entry : ChInfo2)
    fields, values = entry.changes
    @redo.open do |db|
      @repo.upsert(db, "chinfos", fields, values, "(ch_no)", nil) do
        keep_fields = fields.reject(&.== "ch_no")
        @repo.upsert_stmt(keep_fields) { |field| "excluded.#{field}" }
      end
    end
  end

  def get(ch_no : Int32) : ChInfo2?
    query = "select * from chinfos where ch_no = ? limit 1"
    @repo.open(&.query_one? query, ch_no, as: ChInfo2)
  end

  def get_title(ch_no : Int32) : String?
    query = "select title from chinfos where ch_no = ? limit 1"
    @repo.open(&.query_one? query, ch_no, as: String)
  end

  def get_text(ch_no : Int32, pg_no : Int32) : String
    raise "Chương tiết không tồn tại"
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

  # def update!(ttl = 1.hours)
  #   chaps = fetch_remote(ttl)
  #   return if chaps.empty?

  #   @db.transaction do |tx|
  #     cnn = tx.connection
  #     chaps.each do |input|
  #       self.upsert(get_changes(input), cnn, "ch_no")
  #     end
  #   end
  # end

  # private def fetch_remote(ttl = 10.years)
  #   chaps = RemoteInfo.new(@sname, @s_bid, ttl: ttl).chap_infos
  #   (chaps.size > 0 || !@remote || ttl == 1.hours) ? chaps : fetch_remote(1.hours)
  # end

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
    hash = {} of Int32 => ChInfo2

    pages = Dir.glob(File.join(@root_dir, "*.tsv"))
    pages.sort_by! { |x| File.basename(x, ".tsv").to_i }
    pages.each { |x| hash = read_file(x, hash) }

    infos = hash.values.sort_by!(&.ch_no.not_nil!)
    bulk_upsert(infos) unless infos.empty?
  end

  def sync_db!
    hash = {} of Int32 => ChInfo2

    hash = read_file(origs_path, hash) if File.exists?(origs_path)
    hash = read_file(patch_path, hash) if File.exists?(patch_path)

    infos = hash.values.sort_by!(&.ch_no.not_nil!)
    bulk_upsert(infos) unless infos.empty?
  end

  def read_file(file : String | Path, hash = {} of Int32 => self)
    File.read_lines(file).each do |line|
      cols = line.split('\t')
      next if cols.size < 4

      entry = ChInfo2.new(@sn_id, @s_bid, cols)
      hash[entry.ch_no!] = entry
    end

    hash
  end
end
