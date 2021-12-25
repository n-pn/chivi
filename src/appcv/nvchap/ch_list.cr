require "../../_util/ram_cache"
require "./ch_info"

class CV::ChList
  getter data = {} of Int32 => ChInfo
  forward_missing_to data

  def initialize(@file : String, reset = false)
    return if reset || !File.exists?(file)

    File.read_lines(@file).each do |line|
      next unless info = ChInfo.new(line.split('\t'))
      data[info.chidx] = info
    end
  end

  def put!(chinfo : ChInfo)
    @data[chinfo.chidx] = chinfo

    File.open(@file, "a") do |io|
      io << '\n'
      chinfo.to_tsv(io)
    end
  end

  def save!
    File.open(@file, "w") do |io|
      @data.each_value.with_index do |chinfo, idx|
        io << '\n' if idx > 0
        chinfo.to_tsv(io)
      end
    end
  end

  #####################

  DIR = "var/chtexts"

  PSIZE = 128
  CACHE = RamCache(String, self).new(4096, 3.days)

  def self.pgidx(chidx : Int32)
    (chidx - 1) // PSIZE
  end

  def self.load!(sname : String, snvid : String, pgidx : Int32, reset = false)
    fpath = "#{DIR}/#{sname}/#{snvid}/#{pgidx}.tsv"
    CACHE.get(fpath) { new(fpath, reset: reset) }
  end

  # return pgmax + lowest unchanged ch_list pgidx
  def self.save!(sname : String, snvid : String, infos : Array(ChInfo), redo = true)
    pgmax = (infos.size - 1) // PSIZE
    pgmax.downto(0) do |pgidx|
      ch_list = load!(sname, snvid, pgidx, reset: redo)
      changed = false

      i_min = pgidx * PSIZE
      i_max = i_min + PSIZE
      i_max = infos.size if i_max > infos.size

      i_min.upto(i_max - 1) do |idx|
        info = infos.unsafe_fetch(idx)

        unless redo
          break if ch_list[info.chidx]?.try(&.equal?(info))
          changed = true
        end

        ch_list[info.chidx] = info
      end

      return {pgmax, pgidx} unless redo || changed
      ch_list.save!
    end

    {pgmax, 0}
  end
end
