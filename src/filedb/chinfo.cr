require "json"
require "file_utils"
require "compress/zip"

require "../engine/cvmtl"
require "../source/rm_chinfo"
require "../source/rm_chtext"
require "../_utils/ram_cache"

class CV::Chinfo
  DIR = "_db/chdata/chinfos"

  CACHED = RamCache(self).new(256)

  def self.load(bhash : String, sname : String, snvid : String)
    CACHED.get("#{sname}/#{snvid}") { new(bhash, sname, snvid) }
  end

  getter bhash : String
  getter sname : String
  getter snvid : String
  getter cvter : Cvmtl { Cvmtl.generic(bhash) }

  getter origs : ValueMap { ValueMap.new("_db/chdata/zhinfos/#{@sname}/#{@snvid}.tsv") }

  def initialize(@bhash, @sname, @snvid)
    @infos = {} of String => Array(String)

    @info_dir = "_db/chdata/chinfos/#{@sname}/#{@snvid}"
    @text_dir = "_db/chdata/zhtexts/#{@sname}/#{@snvid}"

    {@info_dir, @text_dir}.each { |x| ::FileUtils.mkdir_p(x) }
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

  def get_info(chidx : String)
    @infos[chidx] ||= begin
      orig = origs.get(chidx) || [chidx, ""]
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
    return unless info = get_info(idx.to_s)
    "-#{info[3]}-#{sname}-#{idx + 1}"
  end

  def last(take = 4)
    origs.data.keys.to_a.last(take).each do |chidx|
      yield chidx, get_info(chidx)
    end
  end

  def each(from : Int32 = 0, upto : Int32 = 30)
    from.upto(upto - 1) do |idx|
      chidx = (idx + 1).to_s
      yield chidx, get_info(chidx)
    end
  end

  def save!(mode : Symbol = :full)
    @stats.try(&.save!(mode: mode))
  end

  @cv_times = {} of Int32 => Time
  CV_TRANS = RamCache(String).new(2048)
  ZH_TEXTS = RamCache(Array(String)).new(2048)

  def get_cvdata!(chidx : Int32, schid : String, mode = 0, power = 0)
    key = "#{@sname}/#{@snvid}/#{chidx}"
    CV_TRANS.delete(key) if mode > 0 || outdated?(chidx, ttl: 1.day)

    CV_TRANS.get(key) do
      puts "- <chap_cvdata> [#{sname}/#{snvid}/#{chidx}] converted.".colorize.cyan
      @cv_times[chidx] = Time.utc
      convert(get_zhtext!(chidx, schid, mode > 1, power))
    end
  end

  private def convert(lines : Array(String))
    return "" if lines.empty?

    String.build do |io|
      cvter.cv_title_full(lines[0]).to_str(io)

      1.upto(lines.size - 1) do |i|
        io << "\n"
        para = lines.unsafe_fetch(i)
        cvter.cv_plain(para).to_str(io)
      end
    end
  end

  def outdated?(chidx : Int32, ttl : Time::Span)
    return true unless time = @cv_times[chidx]?
    return time + ttl < Time.utc
  end

  def get_zhtext!(chidx : Int32, schid : String, reset = false, power = 0)
    key = "#{@sname}/#{@snvid}/#{chidx}"

    data = ZH_TEXTS.get(key) { load_zhtext!(chidx, schid) }
    return data unless (reset || data.empty?) && RmSpider.remote?(@sname, power)

    valid = reset ? 3.minutes : 3.years
    ZH_TEXTS.set(key, fetch_zhtext!(chidx, schid, valid: valid) || data)
  end

  def load_zhtext!(chidx : Int32, schid : String)
    zip_file = group_path(chidx - 1)

    if File.exists?(zip_file)
      Compress::Zip::File.open(zip_file) do |zip|
        next unless entry = zip["#{schid}.txt"]?
        return entry.open(&.gets_to_end).split('\n')
      end
    end

    [] of String
  end

  def fetch_zhtext!(chidx : Int32, schid : String, valid = 10.years)
    puller = RmChtext.new(@sname, @snvid, schid, valid: valid)
    lines = [puller.title].concat(puller.paras)
    save_zhtext!(chidx, schid, lines)
    lines
  rescue err
    puts "- Fetch chtext error: #{err}".colorize.red
  end

  def group_path(index : Int32)
    group = (index // 100).to_s.rjust(3, '0')
    zip_file = File.join(@text_dir, group + ".zip")
  end

  def save_zhtext!(chidx : Int32, schid : String, lines : Array(String))
    out_zip = group_path(chidx - 1)
    out_file = File.join(@text_dir, "#{schid}.txt")

    File.open(out_file, "w") { |io| lines.join(io, "\n") }
    puts `zip -jqm "#{out_zip}" "#{out_file}"`
    puts "- <chap_zhtext> [#{out_file}] saved.".colorize.yellow
  end
end
