require "../../cutil/tsv_store"
require "../../cutil/ram_cache"
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

      chidx = group * LSIZE
      (chidx + 1).upto(chidx + LSIZE) do |index|
        break unless infos = data[index]?
        key = (index + 1).to_s

        if prevs = chlist.get(key)
          infos << prevs[3] << prevs[4] << prevs[5] if prevs.size >= 6
        end

        chlist.set!(key, infos)
      end

      break unless redo || chlist.unsaved > 0
      chlist.save!(clean: redo)
    end
  end

  def pgidx(chidx : Int32)
    chidx // LSIZE
  end
end
