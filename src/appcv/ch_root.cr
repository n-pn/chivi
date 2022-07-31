require "../_util/site_link"
require "../_util/file_util"
require "../_init/remote_info"

require "./nvchap/ch_list"
require "./shared/sname_map"

require "./nvseed/*"

class CV::Nvseed
  include Clear::Model

  self.table = "chroots"
  primary_key type: :serial

  # column uid : Int64 = 0_i64 # alternative unique index

  belongs_to nvinfo : Nvinfo
  getter nvinfo : Nvinfo { Nvinfo.load!(self.nvinfo_id) }

  column sname : String = ""
  column snvid : String # seed book id
  column zseed : Int32 = 0

  # seed data

  column status : Int32 = 0 # same as Cvinfo#status
  column shield : Int32 = 0 # same as Cvinfo#shield

  ##########

  column utime : Int64 = 0 # seed page update time as total seconds since the epoch
  column stime : Int64 = 0 # last crawled at

  column last_sname : String = "" # seed's latest chap id
  column last_schid : String = "" # seed's latest chap id
  column chap_count : Int32 = 0   # total chapters

  column seeded : Bool = false

  timestamps

  getter seed_type : Int32 { SnameMap.map_type(sname) }

  getter privi_map : {Int32, Int32, Int32} do
    case self.seed_type
    when 0 then {-1, 0, 0}
    when 3 then {0, 1, 2}
    else        {0, 1, 1}
    end
  end

  def min_privi(chidx : Int32, chars : Int32 = 0)
    privi_map = self.privi_map
    case
    when chidx <= self.free_chap then privi_map[0]
    when chars > 0               then privi_map[1]
    else                              privi_map[2]
    end
  end

  def free_chap
    case chap_count
    when .< 120 then 40
    when .> 360 then 120
    else             chap_count // 3
    end
  end

  TXT_DIR = "var/chtexts"

  def seed_chaps_from_disk!
    on_conflict = ->(req : Clear::SQL::InsertQuery) do
      req.on_conflict("ON CONSTRAINT chinfos_unique_key").do_update do |upd|
        upd.set(<<-SQL).where("excluded.changed_at is not null")
          schid = excluded.schid,
          title = excluded.title,
          chvol = excluded.chvol,
          w_count = excluded.w_count,
          p_count = excluded.p_count,
          viuser_id = excluded.viuser_id,
          mirror_id = excluded.mirror_id,
          changed_at = excluded.changed_at
        SQL
      end
    end

    files = Dir.glob("#{TXT_DIR}/#{self.sname}/#{self.snvid}/*.tsv")
    files.each do |file|
      input = {} of Int16 => Chinfo
      File.read_lines(file).each do |line|
        next if line.empty?
        entry = Chinfo.new(self, line.split('\t'))
        input[entry.chidx] = entry
      end

      puts "- #{input.size} chapters to import!"

      Clear::SQL.transaction do
        input.values.sort_by!(&.chidx).each(&.save(on_conflict: on_conflict))
      end
    end

    self.update!({seeded: true})
  end

  # ------------------------

  def refresh!(mode : Int8 = 1_i8) : Nil
    self.stime = Time.utc.to_unix

    case sname
    when "=base" then self.reload_base!(mode: mode)
    when "=user" then self.reload_user!(mode: mode)
    when .starts_with?('@')
      self.reload_self!(mode: mode)
    else
      if remote?(force: mode > 0)
        self.update_remote!(mode: mode)
      else
        self.reset_cache!
      end
    end

    self.nvinfo.save! if self.nvinfo.changed?
    Nvinfo.cache!(self.nvinfo)
  end

  scope :filter_nvinfo do |nvinfo_id|
    where("nvinfo_id = #{nvinfo_id}").where("shield < 3")
  end

  ########

  CACHED = RamCache(String, self).new(1024)

  def self.load!(nvinfo_id : Int64, sname : String, force = false)
    raise "Quyển sách không tồn tại" unless nvinfo = Nvinfo.load!(nvinfo_id)
    load!(nvinfo, sname, force: force)
  end

  def self.load!(nvinfo : Nvinfo, sname : String, force = false) : self
    CACHED.get("#{nvinfo.id}/#{sname}") do
      upsert!(nvinfo, sname, nvinfo.bhash, force: force)
    end
  end

  def self.cache!(nvseed : Nvseed)
    CACHED.get("#{nvseed.nvinfo_id}/#{nvseed.sname}") { nvseed }
  end

  def self.upsert!(nvinfo : Nvinfo, sname : String, snvid : String, force = true)
    find({nvinfo_id: nvinfo.id, sname: sname}) || init!(nvinfo, sname, snvid)
  end

  def self.init!(nvinfo : Nvinfo, sname : String, snvid = nvinfo.bhash)
    model = new({nvinfo: nvinfo, sname: sname, snvid: snvid})
    model.zseed = SnameMap.zseed(sname)
    model.tap(&.save!)
  end
end
