require "colorize"
require "file_utils"
require "option_parser"

require "tabkv"

require "../shared/bootstrap.cr"

class CV::InitNvinfo
  DIR = "var/nvinfos"
  FileUtils.mkdir_p("#{DIR}/autos")
  FileUtils.mkdir_p("#{DIR}/inits")
  FileUtils.mkdir_p("#{DIR}/users")

  RATING_FIX = Tabkv.new("#{DIR}/rating_fix.tsv", :force)
  STATUS_MAP = Tabkv.new("#{DIR}/status_map.tsv", :force)

  def self.get_scores(btitle : String, author : String)
    if score = RATING_FIX.get("#{btitle}  #{author}")
      score.map(&.to_i)
    else
      [Random.rand(25..50), Random.rand(40..50)]
    end
  end

  def self.get_mtime(file : String) : Int64
    File.info?(file).try(&.modification_time.to_unix) || 0_i64
  end

  getter stores = {
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

  getter authors : Hash(String, CV::Author)

  def initialize(@sname : String, root : String = "autos")
    @s_dir = "#{DIR}/#{root}/#{@sname}"
    @authors = Author.query.to_a.to_h { |x| {x.zname, x} }
  end

  def staled?(snvid : String, atime : Int64)
    get_map(:_index, snvid).ival_64(snvid) <= atime
  end

  private def group_and_basename(type : Symbol, snvid : String, len = 4)
    case @sname
    when "chivi", "users", "local", "zhwenpg"
      {"-", "#{type}"}
    else
      group = snvid.rjust(len, '0')[0..-len]
      {group, "#{type}/#{type}-#{group}"}
    end
  end

  def get_map(type : Symbol, snvid : String, ext = "tsv")
    group, basename = group_and_basename(type, snvid)
    @stores[type][group] ||= Tabkv.new("#{@s_dir}/#{basename}.#{ext}")
  end

  def get_val(type : Symbol, snvid : String) : Array(String)?
    get_map(type, snvid).get(snvid)
  end

  def set_val!(type : Symbol, snvid : String, value)
    get_map(type, snvid).set!(snvid, value)
  end

  def add!(entry, snvid : String, atime = Time.utc.to_unix)
    set_val!(:_index, snvid, [atime.to_s, entry.btitle, entry.author])
    set_val!(:intros, snvid, entry.bintro)
    set_val!(:genres, snvid, entry.genres)
    set_val!(:covers, snvid, entry.bcover)
    set_val!(:status, snvid, map_status(entry.status))
    set_val!(:utimes, snvid, [entry.mftime.to_s, entry.update])
  end

  def save_stores!(dirty = true) : Nil
    @stores.each_value do |maps|
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

    if output = STATUS_MAP.fval(input)
      return [output, input]
    end

    debug_line = input + "\t" + @sname
    File.open("tmp/unmapped-status.log", "a", &.puts(debug_line))

    STATUS_MAP.set(input, "0")
    ["0", input]
  end

  def seed_all!(only_cached = true)
    unless only_cached
      case @sname
      when "chivi", "users", "local", "zhwenpg"
        files = ["#{@s_dir}/_index.tsv"]
      else
        files = Dir.glob("#{@s_dir}/_index/*.tsv")
      end

      files.each do |file|
        group = File.basename(file, ".tsv")
        @stores[:_index][group] ||= Tabkv.new(file)
      end
    end

    @stores[:_index].each_value.with_index(1) do |map, idx|
      seed_part!(map, idx)
    end

    puts "- authors: #{authors.size.colorize.cyan}, \
    nvinfos: #{Nvinfo.query.count.colorize.cyan}"

    @stores[:extras].each_value(&.save!) if @sname != "yousuu"
  end

  def seed_part!(map : Tabkv, idx = 0)
    map.data.each do |snvid, value|
      btitle, author = NvUtil.fix_names(value[1], value[2])
      seed_nvinfo!(snvid, btitle, author)
    end

    puts "- [#{@sname}/seed] <#{idx.colorize.cyan}>, \
            authors: #{authors.size.colorize.cyan}, \
            nvinfos: #{Nvinfo.query.count.colorize.cyan}, \
            zhbooks: #{Zhbook.query.count.colorize.cyan}"
  end

  def seed_nvinfo!(snvid : String, nvinfo_zname : String? = nil, author_zname : String? = nil) : Nil
    unless nvinfo_zname && author_zname
      nvinfo_zname, author_zname = get_names(snvid)
    end

    return unless author = get_author(author_zname, snvid)
    return unless nvinfo = get_nvinfo(author, nvinfo_zname)

    nvinfo.set_genres(get_vi_genres(snvid))
    nvinfo.set_zintro(get_val(:intros, snvid) || [] of String)
    nvinfo.set_bcover(get_map(:covers, snvid).fval(snvid) || "")

    nvinfo.set_status(get_map(:status, snvid).ival(snvid))

    if @sname == "yousuu" || nvinfo.ys_voters == 0
      get_val(:rating, snvid).try do |vals|
        voters, rating = vals.map(&.to_i)
        nvinfo.set_ys_scores(voters, rating)
      end
    end

    if @sname == "yousuu"
      nvinfo.ys_snvid = snvid.to_i64
      nvinfo.ys_utime = get_map(:utimes, snvid).ival_64(snvid)
      nvinfo.set_utime(nvinfo.ys_utime)

      get_val(:origin, snvid).try do |vals|
        nvinfo.pub_name = vals[0].downcase
        nvinfo.pub_link = vals[1]
      end

      extras = get_ys_extras(snvid)
      nvinfo.yslist_count = extras[0]
      nvinfo.yscrit_count = extras[1]
      nvinfo.ys_word_count = extras[2]
      nvinfo.set_shield(extras[3])
    else
      seed_zhbook!(nvinfo, snvid)
    end

    nvinfo.save!
  end

  def seed_zhbook!(nvinfo : Nvinfo, snvid : String)
    zhbook = Zhbook.upsert!(nvinfo, @sname, snvid)
    nvinfo.add_nvseed(zhbook.zseed)

    if zhbook.chap_count == 0
      zhbook.chap_count, zhbook.last_schid = self.fetch_counts(snvid)
    end

    zhbook.save!
  end

  def fetch_counts(snvid : String) : {Int32, String}
    if vals = get_val(:extras, snvid)
      return {vals[0].to_i, vals[1]}
    end

    base_path = "var/chtexts/#{@sname}/_/#{snvid}.tsv"
    FileUtils.mkdir_p(File.dirname(base_path))

    if File.exists?(base_path)
      lines = File.read_lines(base_path)
      infos = lines.compact_map do |line|
        ChInfo.new(line.split('\t')) unless line.empty?
      end
    elsif SeedUtil.remote?(@sname, privi: 5)
      infos = fetch_chinfos!(snvid, ttl)
      ChList.save!(base_path, infos)
    else
      puts "- Missing data for: #{snvid}".colorize.red.bold
      return {0, ""}
    end

    ChList.save!(@sname, snvid, infos)

    if infos.empty?
      puts "#{@sname}/#{snvid} has no chapters!".colorize.red
    end

    last_chap = infos.last? || ChInfo.new(0)
    chap_count, last_schid = last_chap.chidx, last_chap.schid
    set_val!(:extras, snvid, [chap_count.to_s, last_schid])

    {chap_count, last_schid}
  end

  def get_names(snvid : String)
    _, btitle, author = get_map(:_index, snvid).get(snvid).not_nil!
    NvUtil.fix_names(btitle, author)
  end

  def get_ys_extras(snvid : String) : Array(Int32)
    get_val(:extras, snvid).try(&.map(&.to_i)) || [0, 0, 0, 0]
  end

  def get_vi_genres(snvid : String)
    get_val(:genres, snvid).try { |x| BGenre.map_zh(x) } || [] of String
  end

  def get_author(zname : String, snvid : String) : Author?
    return if zname.empty? || zname == "-"
    authors[zname]?.try { |author| return author }
    authors[zname] = Author.upsert!(zname) if should_seed?(snvid)
  end

  def should_seed?(snvid : String)
    case @sname
    when "zxcs_me", "hetushu", "users", "local" then true
    when "yousuu"
      list_count, crit_count = get_ys_extras(snvid)
      list_count > 1 || crit_count > 3
    else
      false
    end
  end

  def get_nvinfo(author : Author, ztitle : String)
    return if ztitle.empty? || ztitle == "-"

    case @sname
    when "hetushu", "rengshu", "xbiquge", "69shu",
         "zhwenpg", "yousuu", "users", "local"
      Nvinfo.upsert!(author, ztitle)
    else
      Nvinfo.get(author, ztitle)
    end
  end

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
end
