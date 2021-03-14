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

  alias Chlist = Array(Array(String))

  def initialize(@bhash, @sname, @snvid)
    @tran_dir = "_db/chdata/chinfos/#{@sname}/#{@snvid}"
    @orig_dir = "_db/chdata/zhinfos/#{@sname}/#{@snvid}"
    @text_dir = "_db/chdata/zhtexts/#{@sname}/#{@snvid}"

    {@tran_dir, @orig_dir, @text_dir}.each { |x| ::FileUtils.mkdir_p(x) }

    @origs = {} of String => ValueMap
    @trans = {} of String => ValueMap
  end

  def load_orig(label : String)
    @origs[label] ||= ValueMap.new("#{@orig_dir}/#{label}.tsv", mode: 1)
  end

  def load_tran(label : String)
    @trans[label] ||= ValueMap.new("#{@tran_dir}/#{label}.tsv", mode: 1)
  end

  def get_state : Tuple(String, Int32, Int32)
    schid, mtime, total = load_tran("last").get("_") || ["", "0", "0"]
    {schid, mtime.to_i, total.to_i}
  end

  def fetch!(power = 4, mode = 2, valid = 5.minutes) : Tuple(Int32, Int32)
    schid, mtime, total = get_state

    if RmSpider.remote?(@sname, power)
      puller = RmChinfo.new(@sname, @snvid, valid: valid)
      if mode > 1 || puller.changed?(schid)
        mtime = puller.update_int.//(60).to_i
        total = puller.chap_list.size

        update!(puller.chap_list, power: power)
      end
    end

    {mtime, total}
  end

  def update!(chlist : Chlist, power : Int32 = 0, mtime : Int32 = 0)
    chlist.each_slice(100).with_index do |list, idx|
      group = idx.to_s.rjust(3, '0')

      tran_map = load_tran(group)
      orig_map = load_orig(group)

      list.each_with_index(idx * 100 + 1) do |infos, idx|
        chidx = idx.to_s

        if power > 1 || orig_map.upsert(chidx, infos)
          update_tran!(tran_map, chidx, infos)
        end
      end

      tran_map.save!(clean: false)
      orig_map.save!(clean: false)
    end

    # save top 6

    orig_last = load_orig("last")
    tran_last = load_tran("last")

    # update state
    tran_last.upsert("_", [chlist.last[0], mtime.to_s, chlist.size.to_s])

    chlist.last(6).each_with_index do |infos, idx|
      chidx = idx.to_s
      if power > 1 || orig_last.upsert(chidx, infos)
        update_tran!(tran_last, chidx, infos)
      end
    end

    tran_last.save!
    orig_last.save!
  end

  def update_tran!(tran_map : ValueMap, chidx : String, infos : Array(String))
    schid = cols[0]
    zh_title = cols[1]
    zh_label = cols[2]? || ""

    vi_title = cvter.tl_title(zh_title)
    vi_label = zh_label.empty? ? "Chính văn" : cvter.tl_title(zh_label)
    url_slug = TextUtils.tokenize(vi_title).first(12).join("-")

    tran_map.upsert(chidx, [schid, vi_title, vi_label, url_slug])
  end

  def retranslate!
    Dir.glob("#{@orig_dir}/*.tsv") do |file|
      label = File.basename(file, ".tsv")

      tran_map = load_tran(group)
      orig_map = load_orig(group)

      orig_map.data.each do |chidx, infos|
        update_tran!(tran_map, chidx, infos)
      end

      tran_map.save!(clean: false)
      orig_map.save!(clean: false)
    end
  end

  def each(skip : Int32 = 0, take : Int32 = 30)
    # TODO: improve performance
    while skip < upto
      tran_map = load_map(skip.to_s.rjust(3, '0'))

      skip += 1
      chidx = skip.to_i
      yield chidx, tran_map.get(chidx)
    end
  end

  def json_each(json : JSON::Builder, skip : Int32, take : Int32)
    json.array do
      each(skip, take, desc) do |chidx, infos|
        json.object do
          json.field "chidx", chidx
          json.field "schid", infos[0]?
          json.field "title", infos[1]?
          json.field "label", infos[2]?
          json.field "uslug", infos[3]?
        end
      rescue err
        puts err
      end
    end
  end

  def url_for(idx : Int32)
    return unless chap = heads[idx]?
    "-#{chap[3]}-#{sname}-#{idx + 1}"
  end

  def save!(mode : Symbol = :full)
    @stats.try(&.save!(mode: mode))
  end

  @cv_times = {} of Int32 => Time
  CV_TRANS = RamCache(String).new(2048)
  ZH_TEXTS = RamCache(Array(String)).new(2048)
  @zh_texts = {} of Int32 => Array(String)

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
