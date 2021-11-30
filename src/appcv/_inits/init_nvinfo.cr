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

    bintro: {} of String => Tabkv,
    bgenre: {} of String => Tabkv,

    covers: {} of String => Tabkv,

    status: {} of String => Tabkv,
    mftime: {} of String => Tabkv,

    rating: {} of String => Tabkv,

    origin: {} of String => Tabkv,
    unique: {} of String => Tabkv,
  }

  def initialize(@sname : String)
    @s_dir = "#{DIR}/inits/#{@sname}"
  end

  private def group_of(snvid : String, len = 4) : String
    case @sname
    when "chivi", "local", "zhwenpg" then "0"
    else                                  snvid.rjust(len, '0')[0..-len]
    end
  end

  def get_map(type : Symbol, snvid : String, ext = "tsv")
    group = group_of(snvid)
    STORES[type][group] ||= Tabkv.new("#{@s_dir}/#{type}/#{type}-#{group}.#{ext}")
  end

  def set_val!(type : Symbol, snvid : String, value)
    get_map(type, snvid).set!(snvid, value)
  end

  def push!(entry, snvid : String, atime = Time.utc.to_unix, reset = false)
    return unless reset || get_map(:_index, snvid).ival_64(snvid) < atime

    set_val!(:_index, snvid, [atime.to_s, entry.btitle, entry.author])
    set_val!(:bintro, snvid, entry.bintro)
    set_val!(:bgenre, snvid, entry.genres)
    set_val!(:covers, snvid, entry.bcover)

    case @sname
    when "yousuu"
      set_val!(:status, snvid, [entry.status, "", entry.shield])
      set_val!(:mftime, snvid, entry.updated_at.to_unix)
      set_val!(:rating, snvid, [entry.voters, entry.rating])
      set_val!(:unique, snvid, [entry.addListTotal, entry.commentCount, entry.word_count])
    else
      set_val!(:status, snvid, map_status(entry.status))
      set_val!(:mftime, snvid, [entry.mftime.to_s, entry.update])
    end
  end

  def save_stores!(dirty = true) : Nil
    STORES.each_value do |map|
      map.each_value(&.save!(dirty: dirty))
    end
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
