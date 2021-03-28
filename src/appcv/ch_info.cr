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

  getter bname : String
  getter sname : String
  getter snvid : String

  getter origs : ValueMap { ValueMap.new(map_file(@snvid, "origs")) }
  getter trans : ValueMap { ValueMap.new(map_file(@snvid, "trans")) }
  getter infos : Array(Array(String)) { trans.data.values }

  getter cvter : Cvmtl { Cvmtl.generic(bname) }

  def initialize(@bname, @sname, @snvid)
    ::FileUtils.mkdir_p("#{DIR}/origs/#{@sname}")
    ::FileUtils.mkdir_p("#{DIR}/trans/#{@sname}")
  end

  private def map_file(name : String, type : String = "trans")
    "#{DIR}/#{type}/#{@sname}/#{name}.tsv"
  end

  # def load_info(label : String)
  #   @infos[label] ||= begin
  #     file = "#{@info_dir}/#{label}.tsv"

  #     unless File.info?(file).try(&.modification_time.> Time.utc - 1.days)
  #       build_info(file, label)
  #     end

  #     ValueMap.new(file, mode: 1)
  #   end
  # end

  # private def build_info(file : String, label : String)
  # end

  def get_info(index : Int32)
    get_info(index.to_s)
  end

  def get_info(chidx : Int32)
    index = (chidx + 1).to_s
    infos[chidx] ||= begin
      orig = origs.get(index) || [index, ""]
      schid = orig[0]

      vi_title = cvter.tl_title(orig[1])
      vi_label = orig[2]?.try { |x| cvter.tl_title(x) } || "Chính văn"
      url_slug = TextUtils.tokenize(vi_title).first(10).join("-")

      [schid, vi_title, vi_label, url_slug]
    end
  end

  PAGE = 100

  def last_schid
    origs.data.last_value?.try(&.first?) || ""
  end

  def fetch!(power = 4, mode = 2, valid = 5.minutes) : Tuple(Int64, Int32)
    mtime = 0_i64

    if RmSpider.remote?(@sname, power)
      puller = RmChinfo.new(@sname, @snvid, valid: valid)

      if mode > 1 || puller.last_chid != last_schid
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

  def trans!(info_map : ValueMap, chidx : String, infos : Array(String))
    schid = cols[0]
    vi_title = cvter.tl_title(cols[1])
    vi_label = cols[2]?.try { |x| cvter.tl_title(x) } || "Chính văn"

    url_slug = TextUtils.tokenize(vi_title).first(10).join("-")
    info_map.set(chidx, [schid, vi_title, vi_label, url_slug])
  end

  # def trans!(redo : Bool = false)

  #   chinfo = origs.data.to_a

  #   chinfo.each_slice(PAGE).with_index do |list, page|
  #     info_map = load_info(page)
  #     list.each { |chidx, infos| update_info!(info_map, chidx, infos) }
  #     info_map.save!(clean: false)
  #   end

  #   update_last!(chinfo.last(6).map(&.[1]))
  # end

  # def update_last!(chaps : Chlist)
  #   tran_map = load_tran("last")
  #   chaps.each_with_index { |infos, idx| update_info!(tran_map, idx.to_s, infos) }
  #   tran_map.save!(clean: false)
  # end

  def url_for(idx : Int32)
    return unless info = get_info(idx)
    "-#{info[3]}-#{sname}-#{idx + 1}"
  end

  def last(take = 4)
    origs.data.keys.to_a.last(take).each do |chidx|
      yield chidx, get_info(chidx.to_i - 1)
    end
  end

  def each(from : Int32 = 0, upto : Int32 = 30)
    from.upto(upto - 1) do |idx|
      chidx = (idx + 1).to_s
      yield chidx, get_info(idx)
    end
  end

  def save!
    @origs.try(&.save!)
    @trans.try(&.save!)
  end
end
