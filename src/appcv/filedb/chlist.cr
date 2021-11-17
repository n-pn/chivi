require "../../_util/tsv_store"
require "../../_util/ram_cache"
require "./chpage"

module CV::Chlist
  extend self

  CHDIR = "db/chtexts"
  LSIZE = 128
  CACHE = RamCache(String, TsvStore).new(4096, 3.days)

  def load!(sname : String, snvid : String, group : Int32)
    fpath = "#{CHDIR}/#{sname}/#{snvid}/#{group}.tsv"
    CACHE.get(fpath) { TsvStore.new(fpath) }
  end

  def save!(sname : String, snvid : String, data : Array(Array(String)), redo = true)
    pages = (data.size - 1) // LSIZE + 1

    (pages - 1).downto(0) do |group|
      chlist = load!(sname, snvid, group)

      start = group * LSIZE
      start.upto(start + LSIZE - 1) do |index|
        break unless infos = data[index]?
        chidx = (index + 1).to_s

        if prevs = chlist.get(chidx)
          infos << prevs[3] << prevs[4] << prevs[5] if prevs.size >= 6
        end

        chlist.set!(chidx, infos)
      end

      break unless redo || chlist.unsaved > 0
      chlist.save!(clean: redo)
    end
  end

  def pgidx(chidx : Int32)
    chidx // LSIZE
  end
end
