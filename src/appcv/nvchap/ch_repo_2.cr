require "./ch_info_2"
require "./ch_list"
require "../shared/sname_map"
require "../../_init/remote_info"

module CV
  class ChRepo2 < Crorm::Repo(ChInfo2)
    DIR = "var/chtexts"

    getter sname : String
    getter snvid : String

    getter db : DB::Database

    def initialize(@sname, @snvid, reset : Bool = false)
      @dir = File.join(DIR, sname, snvid)
      @is_remote = SnameMap.remote?(sname)

      @index_path = File.join(@dir, "index.db")
      @origs_path = File.join(@dir, "origs.tab")
      @stats_path = File.join(@dir, "stats.tab")

      reinit = reset || !File.exists?(@index_path)
      setup_db if reinit

      super(@index_path, "chinfos")
      init_from_old_data if reinit
    end

    def update!(ttl = 1.hours)
      chaps = fetch_remote(ttl)
      return if chaps.empty?

      @db.transaction do |tx|
        cnn = tx.connection
        chaps.each do |input|
          self.upsert(get_changes(input), cnn, "chidx")
        end
      end
    end

    private def fetch_remote(ttl = 10.years)
      chaps = RemoteInfo.new(@sname, @snvid, ttl: ttl).chap_infos
      (chaps.size > 0 || !@is_remote || ttl == 1.hours) ? chaps : fetch_remote(1.hours)
    end

    # #### migrate

    private def setup_db : Nil
      Dir.mkdir_p(@dir)

      if @is_remote
        Dir.mkdir_p("var/books/.html/#{@sname}")
        Dir.mkdir_p("var/chaps/.html/#{@sname}/#{@snvid}")
      end

      `sqlite3 "#{@index_path}" < ./src/_init/sqls/chinfos.sql`
      raise "Can't create sqlite file" unless $?.success?
    end

    def get_changes(input : ChInfo)
      entry = {} of String => DB::Any

      entry["chidx"] = input.chidx
      entry["schid"] = input.schid
      entry["title"] = input.title
      entry["chvol"] = input.chvol

      if stats = input.stats
        entry["utime"] = stats.utime
        entry["uname"] = stats.uname

        entry["w_count"] = stats.chars
        entry["p_count"] = stats.parts
      end

      if proxy = input.proxy
        entry["o_sname"] = proxy.sname
        entry["o_snvid"] = proxy.snvid
        entry["o_chidx"] = proxy.chidx
      end

      entry
    end

    def init_from_old_data : Nil
      @db.transaction do |tx|
        cnn = tx.connection

        files = Dir.glob(File.join(@dir, "*.tsv"))
        files.each do |file|
          infos = ChList.new(file).data
          infos.each_value do |input|
            self.upsert(get_changes(input), cnn, "chidx")
          end
        end
      end
    end
  end
end
