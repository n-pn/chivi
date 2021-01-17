require "json"
require "myhtml"
require "colorize"
require "file_utils"

require "../../src/shared/text_utils"
require "../../src/filedb/nvinfo"
require "../../src/filedb/chseed"
require "../../src/filedb/chinfo"
require "../../src/filedb/_inits/rm_info"

class CV::InfoSeed
  getter name : String
  getter rdir : String

  getter _index : ValueMap { ValueMap.new(map_path("_index")) }

  getter bgenre : ValueMap { ValueMap.new(map_path("bgenre")) }
  getter bcover : ValueMap { ValueMap.new(map_path("bcover")) }

  getter status : ValueMap { ValueMap.new(map_path("status")) }
  getter shield : ValueMap { ValueMap.new(map_path("shield")) }
  getter rating : ValueMap { ValueMap.new(map_path("rating")) }

  getter access_tz : ValueMap { ValueMap.new(map_path("tz_access")) }
  getter update_tz : ValueMap { ValueMap.new(map_path("tz_update")) }

  def initialize(@name)
    @rdir = "_db/_seeds/#{@name}"
    @intro_dir = "#{@rdir}/intros"
    ::FileUtils.mkdir_p(@intro_dir)
  end

  def map_path(fname : String)
    "#{@rdir}/#{fname}.tsv"
  end

  def save!(mode : Symbol = :full)
    @_index.try(&.save!(mode: mode))

    @bgenre.try(&.save!(mode: mode))
    @bcover.try(&.save!(mode: mode))

    @status.try(&.save!(mode: mode))
    @rating.try(&.save!(mode: mode))

    @update_tz.try(&.save!(mode: mode))
    @access_tz.try(&.save!(mode: mode))
  end

  def set_intro(sbid : String, intro : Array(String)) : Nil
    File.write(intro_path(sbid), intro.join("\n"))
  end

  def get_intro(sbid : String) : Array(String)
    File.read_lines(intro_path(sbid))
  rescue err
    [] of String
  end

  def intro_path(sbid)
    "#{@intro_dir}/#{sbid}.txt"
  end

  def get_genres(sbid : String)
    zh_genres = bgenre.get(sbid) || [] of String
    zh_genres = zh_genres.map { |x| NvShared.fix_zh_genre(x) }.flatten.uniq

    vi_genres = zh_genres.map { |x| NvShared.fix_vi_genre(x) }.uniq
    vi_genres.reject!("Loại khác")

    vi_genres.empty? ? ["Loại khác"] : vi_genres
  end

  getter chseed : Chseed { Chseed.load(@name) }

  def upsert!(sbid : String) : Tuple(String, Bool)
    btitle, author = _index.get(sbid).not_nil!
    bhash, existed = Nvinfo.upsert!(btitle, author)

    bintro = get_intro(sbid)
    NvFields.set_bintro(bhash, bintro) unless bintro.empty?

    genres = get_genres(sbid)
    NvFields.set_bgenre(bhash, genres) unless genres.empty?

    mftime = update_tz.ival_64(sbid)
    NvFields.set_update_tz(bhash, mftime)
    NvFields.set_access_tz(bhash, mftime // 60)

    NvFields.set_status(bhash, status.ival(sbid, 0))

    if @name != "yousuu"
      NvFields.set_chseed(bhash, @name, sbid)

      mftime = NvFields.update_tz.ival_64(bhash) if @name == "hetushu"
      chseed.update_tz.add(sbid, mftime)
      chseed.access_tz.add(sbid, access_tz.ival_64(sbid))

      upsert_chinfo!(sbid, bhash, expiry: Time.unix(mftime))
    end

    {bhash, existed}
  end

  def upsert_chinfo!(sbid : String, bhash : String, expiry : Time) : Nil
    chseed._index.add(bhash, sbid)

    parser = RmInfo.init(@name, sbid, expiry: expiry)
    return unless chseed.last_chap.add(sbid, parser.last_chap)

    chaps = parser.chap_list
    chseed.count_chap.add(sbid, chaps.size)

    chinfo = Chinfo.new(@name, sbid)
    cvtool = Convert.content(bhash)

    chaps.each_with_index do |entry, idx|
      scid, title, label = entry

      vals = label.empty? ? [title] : [title, label]
      next unless chinfo._seed.add(scid, vals)

      vi_title = cvtool.tl_title(title)
      vi_label = label.empty? ? "Chính văn" : cvtool.tl_title(label)
      url_slug = TextUtils.tokenize(vi_title).first(12).join("-")

      chinfo.trans.add(scid, [vi_title, vi_label, url_slug])
    end

    chinfo.save!(mode: :full)
  end
end
