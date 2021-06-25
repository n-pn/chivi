require "json"
require "file_utils"

require "../../libcv/cvmtl"
require "../../seeds/rm_info"
require "../../tabkv/value_map"
require "../../cutil/ram_cache"

class CV::ChInfo
  SEED_DIR = "_db/chseed"
  TRAN_DIR = "_db/chtran"

  CACHED = RamCache(self).new(512)

  def self.load(bname : String, sname : String, snvid : String)
    CACHED.get("#{sname}/#{snvid}") { new(bname, sname, snvid) }
  end

  getter seeds : ValueMap { ValueMap.new("#{SEED_DIR}/#{@sname}/#{@snvid}/_id.tsv") }
  getter trans : ValueMap { ValueMap.new("_db/ch_infos/trans/#{@sname}/#{@snvid}.tsv") }

  alias Chitem = Tuple(String, Array(String))
  getter infos : Array(Chitem) do
    trans!(reset: true) if trans.data.empty?
    trans.data.to_a
  end

  def initialize(@bname : String, @sname : String, @snvid : String)
    ::FileUtils.mkdir_p("#{SEED_DIR}/#{@sname}/#{@snvid}")
    ::FileUtils.mkdir_p("#{TRAN_DIR}/#{@sname}/#{@snvid}")
  end

  def set!(chidx : String, schid : String, title : String, label : String)
    seeds.set!(chidx, [schid, title, label])
    trans!(reset: false)
  end

  def fetch!(power = 4, mode = 2, ttl = 5.minutes) : Tuple(Int64, Int32)
    mtime = -1_i64

    if RmUtil.remote?(@sname, power: power)
      RmInfo.mkdir!(@sname)

      parser = RmInfo.new(@sname, @snvid, ttl: ttl)
      latest = seeds.data.last_value?.try(&.first?) || ""

      if mode > 1 || parser.last_schid != latest
        mtime = parser.mftime

        parser.chap_list.each_with_index(1) do |chap, index|
          seeds.set!(index.to_s, chap.to_a)
        end
      end
    end

    {mtime, seeds.size}
  end

  def updated?
    @seeds.try(&.upds.size.> 0)
  end

  def trans!(reset : Bool = false)
    chaps = reset ? seeds.data : seeds.upds
    return if chaps.empty?

    cvmtl = Cvmtl.generic(@bname)

    chaps.each do |chidx, infos|
      vi_title = cvmtl.cv_title(infos[1]).to_s
      url_slug = TextUtils.tokenize(vi_title).first(10).join("-")

      zh_label = infos[2]? || ""
      vi_label = zh_label.empty? ? "Chính văn" : cvmtl.cv_title(zh_label).to_s

      trans.set!(chidx, [infos[0], vi_title, vi_label, url_slug])
    end

    seeds.save!(clean: false)
    trans.save!(clean: false)
    @infos = nil
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
    @seeds.try(&.save!)
    @trans.try(&.save!)
  end
end
