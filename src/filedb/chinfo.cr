require "json"
require "file_utils"

require "./chinfo/*"

require "../source/rm_chinfo"
require "../mapper/zip_store"
require "../engine/cvmtl"

class CV::Chinfo
  DIR = "_db/chdata/chinfos"

  alias Cache = Hash(String, self)
  CACHE_LIMIT = 256

  @@acache = Cache.new(initial_capacity: CACHE_LIMIT)
  @@bcache = Cache.new(initial_capacity: CACHE_LIMIT)

  def self.load(bhash : String, sname : String, snvid : String)
    label = "#{sname}/#{snvid}"

    unless item = @@acache[label]?
      item = @@bcache[label]? || new(bhash, sname, snvid)
      @@acache[label] = item

      if @@acache.size >= CACHE_LIMIT
        @@bcache = @@acache
        @@acache = Cache.new(initial_capacity: CACHE_LIMIT)
      end
    end

    item
  end

  getter bhash : String
  getter sname : String
  getter snvid : String

  alias Chlist = Array(Array(String))
  getter origs : Chlist { load_origs }
  getter heads : Chlist { load_heads }

  getter stats : ValueMap { ValueMap.new(map_path("stats"), mode: 1) }

  def initialize(@bhash, @sname, @snvid)
    @orig_dir = "_db/chdata/zhinfos/#{@sname}/#{@snvid}"
    @text_dir = "_db/chdata/zhtexts/#{@sname}/#{@snvid}"
    @head_file = "_db/chdata/chheads/#{@sname}/#{@snvid}.tsv"

    ::FileUtils.mkdir_p(@orig_dir)
    ::FileUtils.mkdir_p(@text_dir)
  end

  def load_origs
    res = Chlist.new

    files = Dir.glob("#{@orig_dir}/*.tsv").sort_by { |x| File.basename(x, ".tsv").to_i }
    files.each do |file|
      File.read_lines(file).each do |line|
        res << line.split('\t')
      end
    end

    puts "- <chap_zhdata> [#{@sname}/#{@snvid}] loaded".colorize.blue
    res.sort_by(&.first.to_i)
  end

  def save_origs
    origs.each_slice(100).with_index do |list, idx|
      group = idx.to_s.rjust(3, '0')
      file = File.join(@orig_dir, group + ".tsv")
      File.write(file, list.map(&.join('\t')).join('\n'))
    end
  end

  def load_heads
    return Chlist.new unless File.exists?(@head_file)

    puts "- <chap_vpdata> [#{@sname}/#{@snvid}] loaded".colorize.blue
    File.read_lines(@head_file).map(&.split('\t'))
  end

  def save_heads : Nil
    ::FileUtils.mkdir_p(File.dirname(@head_file))
    File.write(@head_file, heads.map(&.join('\t')).join('\n'))
    puts "- <chap_vpdata> [#{@sname}/#{@snvid}] saved (entries: #{heads.size})".colorize.yellow
  end

  def fetch!(power = 4, force = false, valid = 5.minutes) : Tuple(Int32, Int32)
    mtime = -1

    if RmSpider.remote?(@sname, power)
      puller = RmChinfo.new(@sname, @snvid, valid: valid)
      latest = origs.last?.try(&.[1]?) || ""

      if force || puller.changed?(latest)
        mtime = puller.update_int.//(60).to_i
        @origs = puller.chapters
        spawn save_origs
      end
    end

    {mtime, origs.size}
  end

  def trans!(force = false) : Nil
    cvter = Cvmtl.generic(bhash)

    heads.clear if force
    heads.size.upto(origs.size - 1) do |idx|
      row = origs[idx]
      schid = row[1]

      zh_title = row[2]
      zh_label = row[3]? || ""

      vi_title = cvter.tl_title(zh_title)
      vi_label = zh_label.empty? ? "Chính văn" : cvter.tl_title(zh_label)
      url_slug = TextUtils.tokenize(vi_title).first(12).join("-")

      heads << [schid, vi_title, vi_label, url_slug]
    rescue
      next
    end

    spawn save_heads
  end

  delegate size, to: heads

  def each(skip : Int32 = 0, take : Int32 = 30, desc = false)
    return if skip >= heads.size

    upto = skip + take
    upto = heads.size if upto > heads.size

    while skip < upto
      idx = desc ? heads.size - skip - 1 : skip
      yield idx, heads[idx]
      skip += 1
    end
  end

  def json_each(json : JSON::Builder, skip : Int32, take : Int32, desc : Bool)
    json.array do
      each(skip, take, desc) do |idx, row|
        json.object do
          json.field "chidx", idx + 1
          json.field "schid", row[0]
          json.field "title", row[1]
          json.field "label", row[2]
          json.field "uslug", row[3]
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
end
