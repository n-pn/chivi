require "colorize"
require "file_utils"

require "tabkv"

class CV::InitNvinfo
  DIR = "var/nvinfos"
  FileUtils.mkdir_p("#{DIR}/autos")
  FileUtils.mkdir_p("#{DIR}/inits")
  FileUtils.mkdir_p("#{DIR}/users")

  @@rating_fix = Tabkv.new("#{DIR}/rating_fix.tsv", :force)
  @@status_map = Tabkv.new("#{DIR}/status_map.tsv", :force)

  STORES = {
    _index: {} of String => Tabkv,

    intros: {} of String => Tabkv,
    genres: {} of String => Tabkv,
    covers: {} of String => Tabkv,

    status: {} of String => Tabkv,
    utimes: {} of String => Tabkv,
    rating: {} of String => Tabkv,

    origin: {} of String => Tabkv,
    extras: {} of String => Tabkv,
  }

  def initialize(@sname : String, root : String = "autos")
    @s_dir = "#{DIR}/#{root}/#{@sname}"
  end

  def staled?(snvid : String, atime : Int64)
    get_map(:_index, snvid).ival_64(snvid) <= atime
  end

  private def group_and_basename(type : Symbol, snvid : String, len = 4)
    case @sname
    when "chivi", "local", "zhwenpg"
      {"-", "#{type}"}
    else
      group = snvid.rjust(len, '0')[0..-len]
      {group, "#{type}/#{type}-#{group}"}
    end
  end

  def get_map(type : Symbol, snvid : String, ext = "tsv")
    group, basename = group_and_basename(type, snvid)
    STORES[type][group] ||= Tabkv.new("#{@s_dir}/#{basename}.#{ext}")
  end

  def set_val!(type : Symbol, snvid : String, value)
    get_map(type, snvid).set!(snvid, value)
  end

  def add!(entry, snvid : String, atime = Time.utc.to_unix)
    set_val!(:_index, snvid, [atime.to_s, entry.btitle, entry.author])
    set_val!(:intros, snvid, entry.bintro)
    set_val!(:genres, snvid, entry.genres)
    set_val!(:covers, snvid, entry.bcover)

    case entry
    when YsbookRaw
      set_val!(:status, snvid, [entry.status])
      set_val!(:utimes, snvid, entry.updated_at.to_unix)
      set_val!(:rating, snvid, [entry.voters, entry.rating])
      set_val!(:origin, snvid, [entry.pub_name, entry.pub_link])
      set_val!(:extras, snvid, [entry.list_total, entry.crit_count, entry.word_count, entry.shield])
    else
      set_val!(:status, snvid, map_status(entry.status))
      set_val!(:utimes, snvid, [entry.mftime.to_s, entry.update])
    end
  end

  def save_stores!(dirty = true) : Nil
    STORES.each_value do |maps|
      maps.each_value do |map|
        map.save!(dirty: dirty) if map.data.size > 0
      end
    end
  end

  def map_status(input : Int32)
    [input.to_s]
  end

  def map_status(input : String) : Array(String)
    return ["0"] if input.empty? || @sname == "hetushu"

    if output = @@status_map.get(input)
      return [output, input]
    end

    debug_line = input + "\t" + @sname
    File.open("tmp/unmapped-status.log", "a", &.puts(debug_line))

    status_map.set(input, "0")
    ["0", input]
  end

  # def get_index(snvid : String) : Tuple(Int64, String, String)
  #   return {0_i64, "", ""} unless vals = get_map(:index, snvid).get(snvid)

  #   atime, btitle, author = vals
  #   {atime.to_i64, btitle, author}
  # end

  # def get_counts(snvid : String) : Array(Int32)
  #   get_map(:counts, snvid).get(snvid).try(&.map(&.to_i)) || [0, 0, 0]
  # end

  # def get_status(snvid : String) : Array(Int32)
  #   self.status.get(snvid).try(&.map { |x| x.to_i? || 0 }) || [0, 0]
  # end

  # def get_mftime(snvid : String) : Int64
  #   self.mftime.ival_64(snvid)
  # end

  # def get_genres(snvid : String) : Array(String)
  #   self.genres.get(snvid) || [] of String
  # end

  # def get_bcover(snvid : String) : String
  #   # TODO: generate book cover without have to load cover file
  #   @seed.bcover.fval(snvid) || ""
  # end

  # def get_intro(snvid : String) : Array(String)
  #   intro_map(snvid).get(snvid) || [] of String
  # end

  # def get_scores(snvid : String) : Array(Int32)
  #   if scores = self.scores.get(snvid)
  #     scores.map(&.to_i)
  #   elsif scores = SeedUtil.rating_fix.get(get_nlabel(snvid))
  #     scores.map(&.to_i)
  #   elsif @sname == "hetushu" || @sname == "zxcs_me"
  #     [Random.rand(30..100), Random.rand(50..65)]
  #   else
  #     [Random.rand(25..50), Random.rand(40..50)]
  #   end
  # end

  # private def get_nlabel(snvid : String)
  #   _, btitle, author = self._index.get(snvid).not_nil!
  #   "#{btitle}  #{author}"
  # end

  # def get_origin(snvid : String)
  #   self.origin.get(snvid) || ["", ""]
  # end

  # def upsert!(snvid : String, fixed = false) : Tuple(String, String, String)
  #   _, btitle, author = _index.get(snvid).not_nil!
  #   bhash, btitle, author = NvInfo.upsert!(btitle, author, fixed: fixed)

  #   genres = get_genres(snvid)
  #   NvGenres.set!(bhash, genres) unless genres.empty?

  #   bintro = get_intro(snvid)
  #   NvBintro.set!(bhash, bintro, force: false) unless bintro.empty?

  #   NvFields.set_status!(bhash, get_status(snvid))

  #   mftime = update.ival_64(snvid)
  #   NvOrders.set_update!(bhash, mftime)
  #   NvOrders.set_access!(bhash, mftime // 60)

  #   {bhash, btitle, author}
  # end

  # def upsert_chinfo!(bhash : String, snvid : String, mode = 0) : Nil
  #   chinfo = ChInfo.new(bhash, @sname, snvid)

  #   mtime, total = chinfo.fetch!(power: 4, mode: mode, valid: 10.years)
  #   chinfo.trans!(reset: false) if chinfo.updated?

  #   mtime = update.ival_64(snvid) if @sname == "zhwenpg"
  #   NvInfo.new(bhash).set_chseed(@sname, snvid, mtime, total)
  # end
end
