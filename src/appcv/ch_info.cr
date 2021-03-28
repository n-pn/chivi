require "json"
require "file_utils"

require "../libcv/cvmtl"
require "../utils/ram_cache"
require "../seeds/rm_chinfo"

class CV::ChInfo
  DIR = "_db/ch_infos"

  CACHED = RamCache(self).new(512)

  def self.load(bname : String, sname : String, snvid : String)
    CACHED.get("#{sname}/#{snvid}") { new(bname, sname, snvid) }
  end

  getter origs : ValueMap { ValueMap.new(map_file(@snvid, "origs")) }
  getter trans : ValueMap { ValueMap.new(map_file(@snvid, "trans")) }

  alias Chitem = Tuple(String, Array(String))
  getter infos : Array(Chitem) { trans.data.to_a }

  def initialize(@bname : String, @sname : String, @snvid : String)
    ::FileUtils.mkdir_p("#{DIR}/origs/#{@sname}")
    ::FileUtils.mkdir_p("#{DIR}/trans/#{@sname}")
  end

  private def map_file(name : String, type : String = "trans")
    "#{DIR}/#{type}/#{@sname}/#{name}.tsv"
  end

  def fetch!(power = 4, mode = 2, valid = 5.minutes) : Tuple(Int64, Int32)
    mtime = 0_i64

    if RmSpider.remote?(@sname, power)
      puller = RmChinfo.new(@sname, @snvid, valid: valid)

      last_schid = origs.data.last_value?.try(&.first?) || ""

      if mode > 1 || puller.changed?(last_schid)
        mtime = puller.update_int
        total = puller.chap_list.size

        puller.chap_list.each_with_index(1) do |infos, index|
          origs.set!(index.to_s, infos)
        end

        origs.save!(clean: false)
      end
    end

    {mtime, total || origs.size}
  end

  def trans!(reset : Bool = false)
    chaps = reset ? origs.data : origs.upds
    cvmtl = Cvmtl.generic(@bname)

    chaps.each do |chidx, infos|
      vi_title = cvmtl.tl_title(infos[1])
      vi_label = infos[2]?.try { |x| cvmtl.tl_title(x) } || "Chính văn"
      url_slug = TextUtils.tokenize(vi_title).first(10).join("-")

      trans.set!(chidx, [infos[0], vi_title, vi_label, url_slug])
    end

    @infos = nil
    trans.save!
  end

  def url_for(index : Int32)
    return unless info = infos[index]?
    "-#{info[1][3]}-#{@sname}-#{index + 1}"
  end

  def each(from : Int32 = 0, upto : Int32 = 30)
    upto = infos.size if upto > infos.size

    from.upto(upto - 1) do |idx|
      yield infos.unsafe_fetch(idx)
    end
  end

  def last(take = 4)
    from = infos.size - 1
    take = infos.size if take > infos.size

    take.times do |idx|
      yield infos.unsafe_fetch(from - idx)
    end
  end

  def save!
    @origs.try(&.save!)
    @trans.try(&.save!)
  end
end
