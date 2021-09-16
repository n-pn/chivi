require "json"
require "file_utils"

require "../../libcv/mt_core"
require "../../seeds/rm_info"
require "../../seeds/rm_util"
require "../../tsvfs/value_map"
require "../../cutil/ram_cache"

class CV::ChInfo
  SEED_DIR = "_db/chseed"
  TRAN_DIR = "_db/chtran"

  CACHED = {} of String => self

  def self.load(bname : String, sname : String, snvid : String)
    CACHED["#{sname}/#{snvid}"] ||= new(bname, sname, snvid)
  end

  PAGE_SIZE = 32
  LAST_SIZE =  4

  alias Chlist = Array(Array(String))

  getter seeds : Chlist do
    list = Chlist.new

    read_lines(@seed_file) do |values|
      values.shift if values.size == 4
      list << values if values.size > 1
    end

    list
  end

  private def read_lines(file : String)
    return unless File.exists?(file)
    File.each_line(file) do |line|
      yield line.split("\t")
    end
  end

  getter libcv : MtCore { MtCore.generic_mtl(@bname) }

  def initialize(@bname : String, @sname : String, @snvid : String)
    @seed_dir = "#{SEED_DIR}/#{@sname}/#{@snvid}"
    @seed_file = "#{@seed_dir}/_id.tsv"

    @tran_dir = "#{TRAN_DIR}/#{@sname}/#{@snvid}"

    ::FileUtils.mkdir_p(@seed_dir)
    ::FileUtils.mkdir_p(@tran_dir)
  end

  # alias Chtran = Array(Tuple(String, Array(String)))
  @pages = {} of Int32 => ValueMap

  def chaps_page(page : Int32 = 1, preload = true)
    @pages[page] ||= begin
      load_trans(page_fname(page)) do |map|
        offset = (page - 1) * PAGE_SIZE

        offset.upto(offset + PAGE_SIZE - 1).each do |index|
          break unless infos = seeds[index]?
          chidx = index + 1
          map.set!(chidx.to_s, qtran_chap(infos))
        end
      end
    end
  end

  def page_fname(page : Int32 = 1)
    "#{page.to_s.rjust(3, '0')}-#{PAGE_SIZE}"
  end

  def tran_fpath(fname : String)
    "#{@tran_dir}/#{fname}.tsv"
  end

  getter last_chaps : ValueMap do
    load_trans("last-#{LAST_SIZE}") do |map|
      seeds.reverse_each.with_index do |infos, index|
        break if index > 3
        chidx = seeds.size - index
        map.set!(chidx.to_s, qtran_chap(infos))
      end
    end
  end

  private def load_trans(fname : String, mode = 1)
    map = ValueMap.new(tran_fpath(fname), mode: mode)

    if mode == -1 || mode > 0 && map.empty?
      yield map
      map.save!(clean: true)
    end

    map
  end

  getter last_schid : String { seeds[-1]?.try(&.first) || "" }

  def update!(power = 4, mode = 2, ttl = 5.minutes) : Tuple(Int64, Int32, String)
    mftime = 0_i64

    if RmUtil.remote?(@sname, power: power)
      RmInfo.mkdir!(@sname)

      parser = RmInfo.new(@sname, @snvid, ttl: ttl)

      if mode > 1 || parser.last_schid != self.last_schid
        mftime = parser.mftime
        @last_schid = parser.last_schid

        save_seeds!(parser.chap_list)
        reset_trans!
      end
    end

    {mftime, seeds.size, self.last_schid}
  end

  def get_page(index : Int32)
    index // PAGE_SIZE + 1
  end

  def reset_trans!(rmax = get_page(seeds.size), rmin = rmax - 1)
    rmin = 1 if rmin < 1

    rmin.upto(rmax) do |page|
      load_trans(page_fname(page), mode: -1, &.clear)
      @pages.delete(page)
    end

    load_trans("last-#{LAST_SIZE}", mode: -1, &.clear)
    @last_chaps = nil
  end

  def save_seeds!(seeds : Chlist) : Nil
    # TODO: check if the file can be appendable?

    File.write(@seed_file, seeds.map(&.join('\t')).join('\n'))
    @seeds = seeds
  end

  def qtran_chap(infos : Array(String))
    schid = infos[0]

    vi_title = libcv.cv_title(infos[1]).to_s
    url_slug = TextUtils.tokenize(vi_title).first(10).join("-")

    zh_label = infos[2]? || ""
    vi_label = zh_label.empty? ? "Chính văn" : libcv.cv_title(zh_label).to_s

    [schid, vi_title, vi_label, url_slug]
  end

  def put_chap!(index : Int32, schid : String, title : String, label : String)
    if index < seeds.size
      seeds[index] = [schid, title, label]
    else
      seeds << [schid, title, label]
    end

    save_seeds!(seeds)
    reset_trans!
    get_info(index)
  end

  def get_info(index : Int32) : Array(String)?
    page = index // PAGE_SIZE + 1
    chidx = index + 1
    chaps_page(page).get(chidx.to_s)
  end

  def url_for(index : Int32)
    return unless info = get_info(index)
    "-#{info[3]}-#{@sname}-#{index + 1}"
  end
end
