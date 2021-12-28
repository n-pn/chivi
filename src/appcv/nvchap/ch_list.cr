require "../../_util/ram_cache"
require "./ch_info"

class CV::ChList
  DIR = "var/chtexts"

  PSIZE = 128
  CACHE = RamCache(String, self).new(4096, 3.days)

  def self.load!(sname : String, snvid : String, pgidx = 0, reset = false)
    fpath = "#{DIR}/#{sname}/#{snvid}/#{pgidx}.tsv"
    CACHE.get(fpath) { new(fpath, reset: reset) }
  end

  # return pgmax + lowest unchanged ch_list pgidx
  def self.save_many!(sname : String, snvid : String, infos : Array(ChInfo), redo = false)
    upper = infos.size - 1
    pgmax = upper // PSIZE

    while upper > 0
      pgidx = upper // PSIZE
      lower = pgidx * PSIZE

      ch_list = self.load!(sname, snvid, pgidx, reset: redo)
      changed = false

      upper.downto(lower) do |index|
        chinfo = infos.unsafe_fetch(index)

        unless redo
          break if ch_list[chinfo.chidx]?.try(&.equal?(chinfo))
          changed = true
        end

        ch_list[chinfo.chidx] = chinfo
      end

      return {pgmax, pgidx} unless redo || changed

      ch_list.save! if changed
      upper = lower - 1
    end

    {pgmax, 0}
  end

  def self.dup_to_local!(sname : String, snvid : String, bhash : String)
    FileUtils.mkdir_p("#{DIR}/chivi/#{bhash}")
    files = Dir.glob("#{DIR}/#{sname}/#{snvid}/*.tsv")

    files.each do |inp_path|
      inp_list = CACHE.get(inp_path) { new(inp_path) }

      out_path = inp_path.sub("#{sname}/#{snvid}", "chivi/#{bhash}")
      out_list = CACHE.get(out_path) { new(out_path) }

      inp_list.each_value do |inp_info|
        out_info = inp_info.dup
        out_info.o_sname = sname
        out_info.o_snvid = snvid
        out_info.o_chidx = inp_info.chidx
        out_list[out_info.chidx] = out_info
      end

      out_list.save!
    end
  end

  #######

  getter data = {} of Int32 => ChInfo
  forward_missing_to @data

  def initialize(@file : String, reset = false)
    return if reset || !File.exists?(file)
    File.read_lines(file).each do |line|
      info = ChInfo.new(line.split('\t'))
      @data[info.chidx] = info
    end
  end

  def get(chidx : Int32) : ChInfo
    @data[chidx] ||= ChInfo.new(chidx)
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
