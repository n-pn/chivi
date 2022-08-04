require "./ch_info_2"

# require "../appcv/remote/remote_info"

class CV::ChRepo2
  # include Crorm::Query(ChInfo2)

  DIR = "var/chtexts"

  getter sn_id : Int32
  getter s_bid : Int32

  getter infos_path : String { File.join(@root, "infos.tab") }
  getter stats_path : String { File.join(@root, "stats.tab") }

  def initialize(@sname : String, @s_bid, reset : Bool = false)
    @remote = SnameMap.remote?(sname)
    @sn_id = SnameMap.sn_id(sname)
    @root = "#{DIR}/#{sname}/#{s_bid}"
    db_path = File.join(@root, "index.db")

    if File.exists?(db_path)
      File.delete(db_path) if reset
    else
      reset = true
    end

    @repo = Crorm::Adapter.new("sqlite3://#{db_path}")

    return unless reset
    setup_db!
    load_from_tsv_files!(Dir.glob(File.join(@root, "*.tsv")))
  end

  def count
    @repo.scalar("chinfos", "count (*)")
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

  private def setup_db! : Nil
    Dir.mkdir_p(@root)

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

  def load_from_tsv_files!(files : Array(String)) : Nil
    files = files.sort_by { |x| x.to_i? || 0 }
    infos = {} of Int32 => ChInfo2

    files.each do |file|
      lines = File.read_lines(file)
      lines.each do |line|
        rows = line.split('\t')
        next if rows.size < 4
        entry = ChInfo2.new(@sn_id, @s_bid, rows)
        infos[entry.ch_no!] = entry
      end
    end

    bulk_upsert(infos.values.sort_by!(&.ch_no!))
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
end
