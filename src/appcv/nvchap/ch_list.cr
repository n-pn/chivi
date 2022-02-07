require "../../_util/ram_cache"
require "./ch_info"

class CV::ChList
  DIR = "var/chtexts"

  PSIZE = 128
  CACHE = RamCache(String, self).new(4096, 3.days)

  def self.load!(sname : String, snvid : String, pgidx = 0, reset = false)
    fpath = self.path(sname, snvid, pgidx)
    CACHE.get(fpath) { new(fpath, reset: reset) }
  end

  def self.path(sname : String, snvid : String, fname : Int32 | String)
    "#{DIR}/#{sname}/#{snvid}/#{fname}.tsv"
  end

  def self.save!(sname : String, snvid : String, infos : Array(ChInfo))
    return if infos.empty?
    FileUtils.mkdir_p("#{DIR}/#{sname}/#{snvid}")

    input = infos.group_by { |x| (x.chidx - 1) // PSIZE }
    input.each do |pgidx, infos|
      ch_list = load!(sname, snvid, pgidx)
      infos.each { |chinfo| ch_list.add(chinfo) }
      ch_list.save!
    end
  end

  def self.save_all!(sname : String, snvid : String, infos : Array(ChInfo))
    file = "#{DIR}/#{sname}/_/#{snvid}.tsv"
    File.write(file, infos.map(&.to_s).join('\n'))
  end

  def self.save_log!(sname : String, snvid : String, info : ChInfo)
    file = "#{DIR}/#{sname}/_/#{snvid}.log"
    File.open(file, "a") { |io| io << '\n' << info }
  end

  def self.save_log!(sname : String, snvid : String, infos : Array(ChInfo))
    file = "#{DIR}/#{sname}/_/#{snvid}.log"
    File.open(file, "a") do |io|
      infos.each { |info| io << '\n' << info }
    end
  end

  def self.fetch(sname : String, snvid : String, chmin : Int32, chmax : Int32)
    pgmin = (chmin - 1) // PSIZE
    pgmax = (chmax - 1) // PSIZE

    (pgmin..pgmax).each_with_object([] of ChInfo) do |pgidx, output|
      chlist = self.load!(sname, snvid, pgidx)
      chlist.each_value do |chinfo|
        next if chinfo.chidx < chmin || chinfo.chidx > chmax
        output << chinfo.make_copy!(sname, snvid)
      end
    end
  end

  #######

  getter data = {} of Int32 => ChInfo
  forward_missing_to @data

  def initialize(@file : String, reset = false)
    return if reset || !File.exists?(file)
    File.read_lines(file).each do |line|
      next if line.empty?
      info = ChInfo.new(line.split('\t'))
      @data[info.chidx] = info
    rescue err
      File.open("var/_ulogs/chinfo.log", "a") do |io|
        io.puts "#{@file}, #{line}"
      end
    end
  end

  def get(chidx : Int32) : ChInfo
    @data[chidx] ||= ChInfo.new(chidx)
  end

  def add(chinfo : ChInfo)
    if (old_chinfo = @data[chinfo.chidx]?) && chinfo.schid == old_chinfo.schid
      if old_chinfo.utime > chinfo.utime
        chinfo.utime = old_chinfo.utime
        chinfo.chars = old_chinfo.chars
        chinfo.parts = old_chinfo.parts
        chinfo.uname = old_chinfo.uname
      end
    end

    @data[chinfo.chidx] = chinfo
  end

  def update!(chinfo : ChInfo) : Nil
    File.open(@file, "a") { |io| io << '\n' << chinfo }
    @data[chinfo.chidx] = chinfo
  end

  def save!(file : String = @file)
    File.open(file, "w") do |io|
      @data.each_value.with_index do |info, idx|
        io << '\n' if idx > 0
        io << info
      end
    end
  end
end
